#!/usr/bin/env node
const fs = require('fs');
const path = require('path');

const MANIFESTS = new Set([
  'package.json',
  'go.mod',
  'pyproject.toml',
  'requirements.txt',
  'pubspec.yaml',
  'Cargo.toml',
  'pom.xml',
  'composer.json',
  'Gemfile',
]);

const EXCLUDED_DIRS = new Set([
  '.git',
  '.hg',
  '.svn',
  'node_modules',
  'vendor',
  'dist',
  'build',
  'coverage',
  '.next',
  '.nuxt',
  '.svelte-kit',
  '.turbo',
  '.cache',
  '.idea',
  '.vscode-server',
  'context-graph',
]);

function parseArgs(argv) {
  const args = {
    root: process.cwd(),
    out: null,
    title: null,
  };

  for (let i = 0; i < argv.length; i += 1) {
    const arg = argv[i];
    if (arg === '--root') args.root = argv[++i];
    else if (arg === '--out') args.out = argv[++i];
    else if (arg === '--title') args.title = argv[++i];
    else if (arg === '-h' || arg === '--help') {
      printHelp();
      process.exit(0);
    } else {
      throw new Error(`Unknown argument: ${arg}`);
    }
  }

  args.root = path.resolve(args.root);
  args.out = path.resolve(args.out || path.join(args.root, 'context-graph'));
  return args;
}

function printHelp() {
  console.log(`Usage: node export-context-graph.js --root <project-root> [--out <output-dir>] [--title <title>]

Creates:
  <output-dir>/context-graph.html
  <output-dir>/context-graph.js`);
}

function readText(file) {
  try {
    return fs.readFileSync(file, 'utf8');
  } catch (_) {
    return '';
  }
}

function exists(file) {
  return fs.existsSync(file);
}

function rel(root, file) {
  return path.relative(root, file).split(path.sep).join('/');
}

function slug(value) {
  return String(value)
    .toLowerCase()
    .replace(/[`'"()]/g, '')
    .replace(/[^a-z0-9]+/g, '-')
    .replace(/^-+|-+$/g, '')
    .slice(0, 80) || 'node';
}

function firstHeading(markdown) {
  const match = markdown.match(/^#\s+(.+)$/m);
  return match ? match[1].trim() : '';
}

function extractStatus(markdown) {
  const match = markdown.match(/^\s*(?:[-*]\s*)?\*{0,2}(?:Task status|Status):\*{0,2}\s*([^\n<]+)/im);
  if (!match) return '';

  return match[1]
    .replace(/<!--.*?-->/g, '')
    .replace(/[`*_]/g, '')
    .trim();
}

function markdownPayload(root, relativePath) {
  if (!relativePath.endsWith('.md')) return '';

  const text = readText(path.join(root, relativePath));
  if (!text) return '';
  if (text.length <= 180000) return text;
  return text.slice(0, 180000) + '\n\n<!-- truncated for graph export -->';
}

function statusForFile(relativePath, markdown) {
  if (!/^plans\/\d{3}[-_][^/]+\/(?:README|bu|po|dev|qa|ops|stk)\.md$/i.test(relativePath)) {
    return '';
  }

  return extractStatus(markdown);
}

function headingSections(markdown) {
  const headings = [];
  const pattern = /^(#{1,4})\s+(.+)$/gm;
  let match;
  while ((match = pattern.exec(markdown)) !== null) {
    headings.push({
      depth: match[1].length,
      title: match[2].trim(),
      index: match.index,
      end: markdown.length,
    });
  }
  for (let i = 0; i < headings.length - 1; i += 1) {
    headings[i].end = headings[i + 1].index;
  }
  return headings.map((h) => ({
    ...h,
    body: markdown.slice(h.index, h.end),
  }));
}

function walkFiles(root, options = {}) {
  const maxDepth = options.maxDepth ?? 4;
  const files = [];

  function visit(dir, depth) {
    if (depth > maxDepth) return;
    let entries = [];
    try {
      entries = fs.readdirSync(dir, { withFileTypes: true });
    } catch (_) {
      return;
    }

    for (const entry of entries) {
      if (entry.name.startsWith('.') && entry.name !== '.vscode') {
        if (entry.name !== '.env.example') continue;
      }
      const full = path.join(dir, entry.name);
      if (entry.isDirectory()) {
        if (!EXCLUDED_DIRS.has(entry.name)) visit(full, depth + 1);
      } else if (entry.isFile()) {
        files.push(full);
      }
    }
  }

  visit(root, 0);
  return files;
}

function detectServices(root, allFiles) {
  const services = new Map();
  for (const file of allFiles) {
    const base = path.basename(file);
    if (!MANIFESTS.has(base) && !base.endsWith('.csproj')) continue;

    const dir = path.dirname(file);
    const relativeDir = rel(root, dir) || '.';
    if (relativeDir.split('/').length > 3) continue;

    const service = services.get(relativeDir) || {
      id: `service:${relativeDir}`,
      label: relativeDir === '.' ? path.basename(root) : relativeDir,
      path: relativeDir,
      manifests: [],
    };
    service.manifests.push(rel(root, file));
    services.set(relativeDir, service);
  }
  return [...services.values()];
}

function detectPlans(root) {
  const plansRoot = path.join(root, 'plans');
  if (!exists(plansRoot)) return [];

  let entries = [];
  try {
    entries = fs.readdirSync(plansRoot, { withFileTypes: true });
  } catch (_) {
    return [];
  }

  return entries
    .filter((entry) => entry.isDirectory() && /^\d{3}[-_]/.test(entry.name))
    .map((entry) => {
      const dir = path.join(plansRoot, entry.name);
      const readme = path.join(dir, 'README.md');
      const text = readText(readme);
      const status = extractStatus(text) || 'unknown';
      const title = firstHeading(text) || entry.name;
      const roles = ['bu.md', 'po.md', 'dev.md', 'qa.md', 'ops.md', 'stk.md']
        .filter((name) => exists(path.join(dir, name)))
        .map((name) => rel(root, path.join(dir, name)));
      return {
        id: `plan:${entry.name}`,
        label: title.replace(/^#\s*/, ''),
        path: rel(root, dir),
        readme: exists(readme) ? rel(root, readme) : '',
        status,
        roles,
      };
    });
}

function detectReferencedFiles(root, markdown, allFiles) {
  const refs = new Set();
  const markdownLinks = [...markdown.matchAll(/\[[^\]]+\]\(([^)#]+)(?:#[^)]+)?\)/g)];
  for (const match of markdownLinks) {
    const target = match[1].trim();
    if (/^[a-z]+:\/\//i.test(target)) continue;
    const resolved = path.resolve(root, target);
    if (resolved.startsWith(root) && exists(resolved)) refs.add(rel(root, resolved));
  }

  const candidates = allFiles
    .map((file) => rel(root, file))
    .filter((file) => file.length > 3 && file.length < 120);
  for (const candidate of candidates) {
    if (markdown.includes(candidate)) refs.add(candidate);
  }
  return [...refs].sort();
}

function makeGraph(root, title) {
  const contextFile = path.join(root, 'CONTEXT.md');
  if (!exists(contextFile)) {
    throw new Error(`CONTEXT.md not found in ${root}`);
  }

  const contextText = readText(contextFile);
  const allFiles = walkFiles(root, { maxDepth: 5 });
  const services = detectServices(root, allFiles);
  const plans = detectPlans(root);
  const referencedFiles = detectReferencedFiles(root, contextText, allFiles);

  const nodes = new Map();
  const edges = new Map();

  function addNode(id, label, type, extra = {}) {
    if (!nodes.has(id)) {
      nodes.set(id, { id, label, type, ...extra });
    } else {
      nodes.set(id, { ...nodes.get(id), ...extra });
    }
  }

  function addEdge(source, target, label, type = 'depends') {
    if (!nodes.has(source) || !nodes.has(target)) return;
    const id = `${source}->${target}:${label}`;
    edges.set(id, { id, source, target, label, type });
  }

  const projectTitle = title || firstHeading(contextText) || path.basename(root);
  addNode('project', projectTitle, 'project', { path: rel(root, root) || '.', summary: root, start: true });
  addNode('context:CONTEXT.md', 'CONTEXT.md', 'context', { path: 'CONTEXT.md', markdown: contextText });
  addEdge('project', 'context:CONTEXT.md', 'source of truth', 'owns');

  for (const section of headingSections(contextText).filter((h) => h.depth <= 3)) {
    const id = `section:${slug(section.title)}`;
    addNode(id, section.title.replace(/^#+\s*/, ''), 'section', {
      path: 'CONTEXT.md',
      summary: section.body.split('\n').slice(0, 8).join('\n'),
      markdown: section.body,
    });
    addEdge('context:CONTEXT.md', id, 'contains', 'contains');
  }

  const l1Files = ['CLAUDE.md', 'AGENTS.md', 'AGENT.md', 'GEMINI.md'];
  for (const name of l1Files) {
    const file = path.join(root, name);
    if (!exists(file)) continue;
    addNode(`file:${name}`, name, 'agent', { path: name, markdown: markdownPayload(root, name) });
    addEdge(`file:${name}`, 'context:CONTEXT.md', 'reads', 'reads');
    addEdge('project', `file:${name}`, 'agent entry', 'contains');
  }

  for (const name of ['ROLE.md', 'PLAN.md', 'plans/README.md']) {
    const file = path.join(root, name);
    if (!exists(file)) continue;
    const type = name === 'ROLE.md' ? 'role' : 'status';
    const text = markdownPayload(root, name);
    addNode(`file:${name}`, name, type, { path: name, markdown: text });
    addEdge('context:CONTEXT.md', `file:${name}`, name === 'ROLE.md' ? 'role panel' : 'status sync', 'tracks');
  }

  const apiDoc = ['docs/openapi.yaml', 'docs/openapi.yml'].find((name) => exists(path.join(root, name)));
  if (apiDoc) {
    addNode(`file:${apiDoc}`, apiDoc, 'api', { path: apiDoc });
    addEdge('context:CONTEXT.md', `file:${apiDoc}`, 'api contract', 'documents');
  }

  const styleFiles = ['styles/css/tokens.css', 'styles/components/button.html']
    .filter((name) => exists(path.join(root, name)));
  for (const name of styleFiles) {
    addNode(`file:${name}`, name, 'style', { path: name });
    addEdge('context:CONTEXT.md', `file:${name}`, 'style system', 'documents');
  }

  for (const service of services) {
    addNode(service.id, service.label, 'service', {
      path: service.path,
      summary: service.manifests.join(', '),
    });
    addEdge('context:CONTEXT.md', service.id, 'service', 'describes');

    for (const manifest of service.manifests) {
      addNode(`file:${manifest}`, manifest, 'manifest', { path: manifest });
      addEdge(service.id, `file:${manifest}`, 'manifest', 'contains');
    }

    const structurePath = service.path === '.'
      ? 'STRUCTURE.md'
      : `${service.path}/STRUCTURE.md`;
    if (exists(path.join(root, structurePath))) {
      addNode(`file:${structurePath}`, structurePath, 'doc', {
        path: structurePath,
        markdown: markdownPayload(root, structurePath),
      });
      addEdge(service.id, `file:${structurePath}`, 'structure guide', 'documents');
    }
  }

  for (const plan of plans) {
    addNode(plan.id, plan.label, 'plan', {
      path: plan.path,
      status: plan.status,
      summary: `Task status: ${plan.status}`,
      markdown: plan.readme ? markdownPayload(root, plan.readme) : '',
    });
    addEdge('context:CONTEXT.md', plan.id, 'feature plan', 'plans');
    if (nodes.has('file:PLAN.md')) addEdge('file:PLAN.md', plan.id, 'tracks', 'tracks');
    if (nodes.has('file:plans/README.md')) addEdge('file:plans/README.md', plan.id, 'indexes', 'indexes');

    if (plan.readme) {
      const readmeMarkdown = markdownPayload(root, plan.readme);
      addNode(`file:${plan.readme}`, path.basename(plan.path), 'plan-file', {
        path: plan.readme,
        status: extractStatus(readmeMarkdown) || plan.status,
        markdown: readmeMarkdown,
      });
      addEdge(plan.id, `file:${plan.readme}`, 'readme', 'contains');
    }

    for (const rolePath of plan.roles) {
      const roleName = path.basename(rolePath, '.md').toUpperCase();
      const roleMarkdown = markdownPayload(root, rolePath);
      addNode(`file:${rolePath}`, `${path.basename(plan.path)} ${roleName}`, 'plan-role', {
        path: rolePath,
        status: extractStatus(roleMarkdown),
        markdown: roleMarkdown,
      });
      addEdge(plan.id, `file:${rolePath}`, roleName, 'role-split');
    }
  }

  for (const file of referencedFiles) {
    if (file === 'CONTEXT.md') continue;
    const id = `file:${file}`;
    const type = file.endsWith('.md') ? 'doc' : 'file';
    const markdown = markdownPayload(root, file);
    addNode(id, file, type, {
      path: file,
      markdown,
      status: statusForFile(file, markdown),
    });
    addEdge('context:CONTEXT.md', id, 'mentions', 'mentions');
  }

  const markdownDocs = allFiles
    .map((file) => rel(root, file))
    .filter((file) => file.endsWith('.md'))
    .filter((file) => !file.startsWith('plans/') || file === 'plans/README.md')
    .filter((file) => !['CONTEXT.md', ...l1Files, 'ROLE.md', 'PLAN.md'].includes(file))
    .slice(0, 80);
  for (const file of markdownDocs) {
    const id = `file:${file}`;
    const markdown = markdownPayload(root, file);
    addNode(id, file, 'doc', { path: file, markdown, status: statusForFile(file, markdown) });
    addEdge('project', id, 'project doc', 'contains');
  }

  const graph = {
    meta: {
      title: projectTitle,
      generatedAt: new Date().toISOString(),
      root,
      startNodeId: 'project',
      nodeCount: nodes.size,
      edgeCount: edges.size,
    },
    nodes: [...nodes.values()],
    edges: [...edges.values()],
  };
  graph.meta.nodeCount = graph.nodes.length;
  graph.meta.edgeCount = graph.edges.length;
  return graph;
}

function htmlTemplate(title) {
  return `<!doctype html>
<html lang="en">
<head>
  <meta charset="utf-8">
  <meta name="viewport" content="width=device-width, initial-scale=1">
  <title>${escapeHtml(title)} context graph</title>
  <style>
    :root {
      --bg: #f6f7f9;
      --panel: #ffffff;
      --ink: #171a1f;
      --muted: #667085;
      --line: #d8dde6;
      --accent: #0f766e;
    }
    * { box-sizing: border-box; }
    body {
      margin: 0;
      background: var(--bg);
      color: var(--ink);
      font: 14px/1.45 Inter, ui-sans-serif, system-ui, -apple-system, BlinkMacSystemFont, "Segoe UI", sans-serif;
    }
    header {
      height: 72px;
      display: flex;
      align-items: center;
      justify-content: space-between;
      gap: 18px;
      padding: 0 24px;
      border-bottom: 1px solid var(--line);
      background: rgba(255,255,255,.92);
      backdrop-filter: blur(10px);
    }
    h1 {
      margin: 0;
      font-size: 20px;
      font-weight: 700;
      letter-spacing: 0;
    }
    .meta { color: var(--muted); font-size: 12px; }
    .layout {
      height: calc(100vh - 72px);
      display: grid;
      grid-template-columns: minmax(0, 1fr) 340px;
    }
    .graph-wrap {
      position: relative;
      overflow: hidden;
      min-width: 0;
      cursor: grab;
      touch-action: none;
    }
    .graph-wrap.is-panning {
      cursor: grabbing;
    }
    .toolbar {
      position: absolute;
      z-index: 2;
      top: 16px;
      left: 16px;
      right: 16px;
      display: flex;
      gap: 10px;
      align-items: center;
      flex-wrap: wrap;
    }
    input, select, button {
      height: 36px;
      border: 1px solid var(--line);
      border-radius: 6px;
      background: var(--panel);
      color: var(--ink);
      padding: 0 10px;
      font: inherit;
      box-shadow: 0 1px 2px rgba(17, 24, 39, .04);
    }
    input { width: min(360px, 45vw); }
    button { cursor: pointer; }
    button:hover { border-color: var(--accent); }
    .icon-button {
      width: 36px;
      padding: 0;
      font-size: 18px;
      line-height: 1;
    }
    .zoom-readout {
      min-width: 56px;
      height: 36px;
      display: inline-flex;
      align-items: center;
      justify-content: center;
      border: 1px solid var(--line);
      border-radius: 6px;
      background: var(--panel);
      color: var(--muted);
      box-shadow: 0 1px 2px rgba(17, 24, 39, .04);
      font-size: 12px;
    }
    svg {
      width: 100%;
      height: 100%;
      display: block;
      user-select: none;
    }
    aside {
      border-left: 1px solid var(--line);
      background: var(--panel);
      min-width: 0;
      overflow: auto;
      padding: 18px;
    }
    .stat-grid {
      display: grid;
      grid-template-columns: repeat(2, minmax(0, 1fr));
      gap: 8px;
      margin-bottom: 16px;
    }
    .stat {
      border: 1px solid var(--line);
      border-radius: 8px;
      padding: 10px;
      background: #fbfcfe;
    }
    .stat strong { display: block; font-size: 18px; }
    .detail {
      border-top: 1px solid var(--line);
      padding-top: 14px;
      white-space: pre-wrap;
      overflow-wrap: anywhere;
    }
    .detail-actions {
      display: flex;
      gap: 8px;
      margin: 12px 0;
    }
    .md-viewer {
      max-height: 42vh;
      margin: 0;
      overflow: auto;
      border: 1px solid var(--line);
      border-radius: 8px;
      background: #0f172a;
      color: #e5e7eb;
      padding: 12px;
      font: 12px/1.5 ui-monospace, SFMono-Regular, Menlo, Monaco, Consolas, "Liberation Mono", monospace;
      white-space: pre-wrap;
      overflow-wrap: anywhere;
    }
    .legend {
      display: flex;
      flex-wrap: wrap;
      gap: 8px;
      margin: 12px 0 18px;
    }
    .chip {
      border: 1px solid var(--line);
      border-radius: 999px;
      padding: 4px 8px;
      color: var(--muted);
      background: #fbfcfe;
      font-size: 12px;
    }
    .node text {
      pointer-events: none;
      font-size: 11px;
      fill: #20242b;
      paint-order: stroke;
      stroke: rgba(255,255,255,.88);
      stroke-width: 4px;
    }
    .node circle {
      cursor: grab;
      stroke: white;
      stroke-width: 2px;
      filter: drop-shadow(0 3px 5px rgba(17, 24, 39, .18));
    }
    .node:active circle { cursor: grabbing; }
    .start-ring {
      fill: none;
      stroke: #f59e0b;
      stroke-width: 3px;
      stroke-dasharray: 4 5;
      pointer-events: none;
      animation: startPulse 1.6s ease-in-out infinite;
    }
    .start-label {
      fill: #92400e;
      font-size: 10px;
      font-weight: 700;
      letter-spacing: 0;
      paint-order: stroke;
      stroke: rgba(255,255,255,.9);
      stroke-width: 3px;
    }
    @keyframes startPulse {
      0%, 100% { opacity: .55; }
      50% { opacity: 1; }
    }
    .status-pill {
      fill: rgba(255,255,255,.96);
      stroke: rgba(102,112,133,.35);
      stroke-width: 1px;
    }
    .status-text {
      fill: #344054;
      font-size: 9px;
      font-weight: 700;
      letter-spacing: 0;
      paint-order: stroke;
      stroke: rgba(255,255,255,.9);
      stroke-width: 2px;
    }
    .link {
      stroke: #98a2b3;
      stroke-opacity: .55;
      stroke-width: 1.4px;
    }
    .link-label {
      fill: #667085;
      font-size: 10px;
      paint-order: stroke;
      stroke: rgba(246,247,249,.9);
      stroke-width: 3px;
    }
    @media (max-width: 840px) {
      header { height: auto; align-items: flex-start; flex-direction: column; padding: 14px 16px; }
      .layout { height: auto; min-height: calc(100vh - 96px); grid-template-columns: 1fr; }
      .graph-wrap { height: 68vh; }
      aside { border-left: 0; border-top: 1px solid var(--line); }
      input { width: 100%; flex: 1 1 180px; }
    }
  </style>
</head>
<body>
  <header>
    <div>
      <h1>${escapeHtml(title)} context graph</h1>
      <div class="meta" data-generated></div>
    </div>
    <div class="meta">Static export: HTML + JS</div>
  </header>
  <main class="layout">
    <section class="graph-wrap">
      <div class="toolbar">
        <input data-search type="search" placeholder="Search nodes or paths">
        <select data-type-filter aria-label="Filter by type"></select>
        <button class="icon-button" data-zoom-out type="button" title="Zoom out" aria-label="Zoom out">−</button>
        <span class="zoom-readout" data-zoom-readout>100%</span>
        <button class="icon-button" data-zoom-in type="button" title="Zoom in" aria-label="Zoom in">+</button>
        <button data-start type="button">Start</button>
        <button data-reset type="button">Reset</button>
      </div>
      <svg data-graph role="img" aria-label="Context dependency graph"></svg>
    </section>
    <aside>
      <div class="stat-grid">
        <div class="stat"><span>Nodes</span><strong data-node-count>0</strong></div>
        <div class="stat"><span>Edges</span><strong data-edge-count>0</strong></div>
      </div>
      <div class="legend" data-legend></div>
      <div class="detail" data-detail>Select a node to inspect its context dependency.</div>
      <div class="detail-actions">
        <button data-view-md type="button" disabled>View MD</button>
      </div>
      <pre class="md-viewer" data-md-viewer hidden></pre>
    </aside>
  </main>
  <script src="./context-graph.js"></script>
</body>
</html>
`;
}

function escapeHtml(value) {
  return String(value)
    .replace(/&/g, '&amp;')
    .replace(/</g, '&lt;')
    .replace(/>/g, '&gt;')
    .replace(/"/g, '&quot;');
}

function jsTemplate(graph) {
  return `window.ICONTEXT_GRAPH = ${JSON.stringify(graph, null, 2)};

(function () {
  const graph = window.ICONTEXT_GRAPH;
  const svg = document.querySelector('[data-graph]');
  const graphWrap = document.querySelector('.graph-wrap');
  const search = document.querySelector('[data-search]');
  const typeFilter = document.querySelector('[data-type-filter]');
  const detail = document.querySelector('[data-detail]');
  const legend = document.querySelector('[data-legend]');
  const generated = document.querySelector('[data-generated]');
  const nodeCount = document.querySelector('[data-node-count]');
  const edgeCount = document.querySelector('[data-edge-count]');
  const reset = document.querySelector('[data-reset]');
  const zoomIn = document.querySelector('[data-zoom-in]');
  const zoomOut = document.querySelector('[data-zoom-out]');
  const zoomReadout = document.querySelector('[data-zoom-readout]');
  const startButton = document.querySelector('[data-start]');
  const viewMd = document.querySelector('[data-view-md]');
  const mdViewer = document.querySelector('[data-md-viewer]');

  const colors = {
    project: '#0f766e',
    context: '#2563eb',
    section: '#7c3aed',
    agent: '#475467',
    role: '#b45309',
    status: '#c2410c',
    service: '#0e7490',
    manifest: '#64748b',
    api: '#be123c',
    style: '#15803d',
    plan: '#9333ea',
    'plan-file': '#a855f7',
    'plan-role': '#d946ef',
    doc: '#334155',
    file: '#667085'
  };

  const viewport = {
    x: 0,
    y: 0,
    k: 1
  };

  const state = {
    type: 'all',
    query: '',
    selected: null,
    nodes: graph.nodes.map((node, index) => ({
      ...node,
      x: 180 + (index % 8) * 90,
      y: 160 + Math.floor(index / 8) * 70,
      vx: 0,
      vy: 0
    })),
    edges: graph.edges.slice()
  };

  const byId = new Map(state.nodes.map((node) => [node.id, node]));
  state.edges = state.edges
    .map((edge) => ({ ...edge, sourceNode: byId.get(edge.source), targetNode: byId.get(edge.target) }))
    .filter((edge) => edge.sourceNode && edge.targetNode);

  const startNode = byId.get(graph.meta.startNodeId) || state.nodes.find((node) => node.start) || state.nodes[0];

  generated.textContent = 'Generated ' + new Date(graph.meta.generatedAt).toLocaleString();
  nodeCount.textContent = graph.nodes.length;
  edgeCount.textContent = graph.edges.length;

  const types = ['all', ...Array.from(new Set(graph.nodes.map((node) => node.type))).sort()];
  typeFilter.innerHTML = types.map((type) => '<option value="' + type + '">' + type + '</option>').join('');
  legend.innerHTML = types.filter((type) => type !== 'all').map((type) => {
    return '<span class="chip"><span style="display:inline-block;width:9px;height:9px;border-radius:50%;background:' +
      (colors[type] || '#667085') + ';margin-right:6px"></span>' + type + '</span>';
  }).join('');

  let width = 900;
  let height = 620;
  let draggingNode = null;
  let panStart = null;
  let pointerStart = null;
  let pointerMoved = false;
  let alpha = 1;
  let raf = 0;
  let mdOpen = false;

  search.addEventListener('input', () => {
    state.query = search.value.trim().toLowerCase();
    wake(0.7);
  });
  typeFilter.addEventListener('change', () => {
    state.type = typeFilter.value;
    wake(0.7);
  });
  reset.addEventListener('click', () => {
    state.type = 'all';
    state.query = '';
    state.selected = null;
    search.value = '';
    typeFilter.value = 'all';
    fitToView();
    wake(0.9);
  });
  zoomIn.addEventListener('click', () => {
    zoomAt(1.18, { x: width / 2, y: height / 2 });
  });
  zoomOut.addEventListener('click', () => {
    zoomAt(1 / 1.18, { x: width / 2, y: height / 2 });
  });
  startButton.addEventListener('click', () => {
    focusStart();
  });
  viewMd.addEventListener('click', () => {
    mdOpen = !mdOpen;
    updateMarkdownViewer();
  });
  svg.addEventListener('wheel', (event) => {
    event.preventDefault();
    const factor = event.deltaY < 0 ? 1.12 : 1 / 1.12;
    zoomAt(factor, svgClientPoint(event));
  }, { passive: false });
  svg.addEventListener('pointerdown', (event) => {
    const group = event.target.closest ? event.target.closest('.node') : null;
    pointerStart = svgClientPoint(event);
    pointerMoved = false;
    svg.setPointerCapture(event.pointerId);

    if (group && group.dataset.nodeId) {
      draggingNode = byId.get(group.dataset.nodeId);
      selectNode(draggingNode, false);
      wake(0.9);
      return;
    }

    panStart = {
      pointer: pointerStart,
      x: viewport.x,
      y: viewport.y
    };
    graphWrap.classList.add('is-panning');
  });
  svg.addEventListener('pointermove', (event) => {
    if (!draggingNode && !panStart) return;
    const point = svgClientPoint(event);
    pointerMoved = pointerMoved || Math.hypot(point.x - pointerStart.x, point.y - pointerStart.y) > 4;

    if (draggingNode) {
      const graphPoint = screenToGraph(point);
      draggingNode.x = graphPoint.x;
      draggingNode.y = graphPoint.y;
      draggingNode.vx = 0;
      draggingNode.vy = 0;
      wake(0.45);
      draw();
      return;
    }

    viewport.x = panStart.x + point.x - panStart.pointer.x;
    viewport.y = panStart.y + point.y - panStart.pointer.y;
    updateZoomReadout();
    draw();
  });
  svg.addEventListener('pointerup', (event) => {
    const group = event.target.closest ? event.target.closest('.node') : null;
    if (!pointerMoved && group && group.dataset.nodeId) {
      selectNode(byId.get(group.dataset.nodeId));
    }
    draggingNode = null;
    panStart = null;
    graphWrap.classList.remove('is-panning');
    wake(0.35);
  });
  svg.addEventListener('pointercancel', () => {
    draggingNode = null;
    panStart = null;
    graphWrap.classList.remove('is-panning');
  });

  function visibleNode(node) {
    const typeOk = state.type === 'all' || node.type === state.type;
    const query = state.query;
    const queryOk = !query ||
      node.label.toLowerCase().includes(query) ||
      (node.path || '').toLowerCase().includes(query) ||
      (node.status || '').toLowerCase().includes(query) ||
      (node.summary || '').toLowerCase().includes(query) ||
      (node.markdown || '').toLowerCase().includes(query);
    return typeOk && queryOk;
  }

  function layout() {
    width = svg.clientWidth || 900;
    height = svg.clientHeight || 620;
    const visible = state.nodes.filter(visibleNode);
    const visibleIds = new Set(visible.map((node) => node.id));
    const links = state.edges.filter((edge) => visibleIds.has(edge.source) && visibleIds.has(edge.target));
    const center = screenToGraph({ x: width / 2, y: height / 2 });

    for (const edge of links) {
      const a = edge.sourceNode;
      const b = edge.targetNode;
      const dx = b.x - a.x;
      const dy = b.y - a.y;
      const distance = Math.sqrt(dx * dx + dy * dy) || 1;
      const desired = edge.type === 'contains' ? 95 : 145;
      const force = (distance - desired) * 0.014 * alpha;
      const fx = (dx / distance) * force;
      const fy = (dy / distance) * force;
      if (a !== draggingNode) { a.vx += fx; a.vy += fy; }
      if (b !== draggingNode) { b.vx -= fx; b.vy -= fy; }
    }

    for (let i = 0; i < visible.length; i += 1) {
      for (let j = i + 1; j < visible.length; j += 1) {
        const a = visible[i];
        const b = visible[j];
        const dx = b.x - a.x;
        const dy = b.y - a.y;
        const distanceSq = Math.max(dx * dx + dy * dy, 80);
        const force = (680 / distanceSq) * alpha;
        const distance = Math.sqrt(distanceSq);
        const fx = (dx / distance) * force;
        const fy = (dy / distance) * force;
        if (a !== draggingNode) { a.vx -= fx; a.vy -= fy; }
        if (b !== draggingNode) { b.vx += fx; b.vy += fy; }
      }
    }

    for (const node of visible) {
      const anchorBias = node.start ? 0.05 : node.type === 'context' ? 0.025 : 0.007;
      if (node !== draggingNode) {
        node.vx += (center.x - node.x) * anchorBias * alpha;
        node.vy += (center.y - node.y) * anchorBias * alpha;
        node.vx *= 0.82;
        node.vy *= 0.82;
        node.x += node.vx;
        node.y += node.vy;
      }
    }
  }

  function draw() {
    width = svg.clientWidth || 900;
    height = svg.clientHeight || 620;
    const visible = state.nodes.filter(visibleNode);
    const visibleIds = new Set(visible.map((node) => node.id));
    const links = state.edges.filter((edge) => visibleIds.has(edge.source) && visibleIds.has(edge.target));
    svg.innerHTML = '';

    const viewportLayer = document.createElementNS('http://www.w3.org/2000/svg', 'g');
    const linkLayer = document.createElementNS('http://www.w3.org/2000/svg', 'g');
    const labelLayer = document.createElementNS('http://www.w3.org/2000/svg', 'g');
    const nodeLayer = document.createElementNS('http://www.w3.org/2000/svg', 'g');
    viewportLayer.setAttribute('transform', 'translate(' + viewport.x + ',' + viewport.y + ') scale(' + viewport.k + ')');
    viewportLayer.append(linkLayer, labelLayer, nodeLayer);
    svg.appendChild(viewportLayer);

    for (const edge of links) {
      const line = document.createElementNS('http://www.w3.org/2000/svg', 'line');
      line.setAttribute('class', 'link');
      line.setAttribute('x1', edge.sourceNode.x);
      line.setAttribute('y1', edge.sourceNode.y);
      line.setAttribute('x2', edge.targetNode.x);
      line.setAttribute('y2', edge.targetNode.y);
      linkLayer.appendChild(line);

      const label = document.createElementNS('http://www.w3.org/2000/svg', 'text');
      label.setAttribute('class', 'link-label');
      label.setAttribute('x', (edge.sourceNode.x + edge.targetNode.x) / 2);
      label.setAttribute('y', (edge.sourceNode.y + edge.targetNode.y) / 2);
      label.textContent = edge.label;
      labelLayer.appendChild(label);
    }

    for (const node of visible) {
      const group = document.createElementNS('http://www.w3.org/2000/svg', 'g');
      group.setAttribute('class', 'node');
      group.dataset.nodeId = node.id;
      group.setAttribute('transform', 'translate(' + node.x + ',' + node.y + ')');

      const circle = document.createElementNS('http://www.w3.org/2000/svg', 'circle');
      const degree = links.filter((edge) => edge.source === node.id || edge.target === node.id).length;
      const radius = Math.min(22, 9 + degree * 1.4);
      if (node.start) {
        const ring = document.createElementNS('http://www.w3.org/2000/svg', 'circle');
        ring.setAttribute('class', 'start-ring');
        ring.setAttribute('r', radius + 8);
        group.appendChild(ring);

        const startLabel = document.createElementNS('http://www.w3.org/2000/svg', 'text');
        startLabel.setAttribute('class', 'start-label');
        startLabel.setAttribute('text-anchor', 'middle');
        startLabel.setAttribute('dy', -radius - 12);
        startLabel.textContent = 'START';
        group.appendChild(startLabel);
      }
      circle.setAttribute('r', radius);
      circle.setAttribute('fill', colors[node.type] || '#667085');
      if (state.selected && state.selected.id === node.id) {
        circle.setAttribute('stroke', '#111827');
        circle.setAttribute('stroke-width', '3');
      }

      const text = document.createElementNS('http://www.w3.org/2000/svg', 'text');
      text.setAttribute('text-anchor', 'middle');
      text.setAttribute('dy', 28);
      text.textContent = compactLabel(node.label);

      group.append(circle, text);
      if (node.status && node.status !== 'unknown') {
        const statusText = compactStatus(node.status);
        const pillWidth = Math.max(42, statusText.length * 5.8 + 14);
        const pill = document.createElementNS('http://www.w3.org/2000/svg', 'rect');
        pill.setAttribute('class', 'status-pill');
        pill.setAttribute('x', -pillWidth / 2);
        pill.setAttribute('y', 36);
        pill.setAttribute('width', pillWidth);
        pill.setAttribute('height', 16);
        pill.setAttribute('rx', 8);

        const pillText = document.createElementNS('http://www.w3.org/2000/svg', 'text');
        pillText.setAttribute('class', 'status-text');
        pillText.setAttribute('text-anchor', 'middle');
        pillText.setAttribute('dy', 47);
        pillText.textContent = statusText;
        group.append(pill, pillText);
      }
      nodeLayer.appendChild(group);
    }
    updateZoomReadout();
  }

  function selectNode(node, shouldDraw = true) {
    if (!node) return;
    state.selected = node;
    mdOpen = false;
    const related = state.edges
      .filter((edge) => edge.source === node.id || edge.target === node.id)
      .map((edge) => {
        const other = edge.source === node.id ? byId.get(edge.target) : byId.get(edge.source);
        return '- ' + edge.label + ': ' + (other ? other.label : edge.target);
      })
      .slice(0, 24)
      .join('\\n');
    detail.textContent = [
      node.label,
      '',
      'Type: ' + node.type,
      node.start ? 'Start: yes' : '',
      node.path ? 'Path: ' + node.path : '',
      node.status ? 'Status: ' + node.status : '',
      node.summary ? '\\n' + node.summary : '',
      related ? '\\nDependencies:\\n' + related : ''
    ].filter(Boolean).join('\\n');
    updateMarkdownViewer();
    if (shouldDraw) draw();
  }

  function compactLabel(label) {
    const value = String(label);
    return value.length > 34 ? value.slice(0, 31) + '...' : value;
  }

  function compactStatus(status) {
    const value = String(status).replace(/\\s+/g, ' ').trim();
    return value.length > 28 ? value.slice(0, 25) + '...' : value;
  }

  function updateMarkdownViewer() {
    const markdown = state.selected && state.selected.markdown ? state.selected.markdown : '';
    viewMd.disabled = !markdown;
    viewMd.textContent = mdOpen ? 'Hide MD' : 'View MD';
    mdViewer.hidden = !mdOpen || !markdown;
    mdViewer.textContent = markdown;
  }

  function svgClientPoint(event) {
    const rect = svg.getBoundingClientRect();
    return {
      x: event.clientX - rect.left,
      y: event.clientY - rect.top
    };
  }

  function screenToGraph(point) {
    return {
      x: (point.x - viewport.x) / viewport.k,
      y: (point.y - viewport.y) / viewport.k
    };
  }

  function zoomAt(factor, point) {
    const before = screenToGraph(point);
    viewport.k = Math.max(0.35, Math.min(2.8, viewport.k * factor));
    viewport.x = point.x - before.x * viewport.k;
    viewport.y = point.y - before.y * viewport.k;
    updateZoomReadout();
    draw();
  }

  function fitToView() {
    width = svg.clientWidth || 900;
    height = svg.clientHeight || 620;
    viewport.x = 0;
    viewport.y = 0;
    viewport.k = 1;
    const cx = width / 2;
    const cy = height / 2;
    state.nodes.forEach((node, index) => {
      const ring = 90 + (index % 5) * 42;
      const angle = (index / Math.max(1, state.nodes.length)) * Math.PI * 2;
      node.x = cx + Math.cos(angle) * ring;
      node.y = cy + Math.sin(angle) * ring;
      node.vx = 0;
      node.vy = 0;
    });
  }

  function focusStart() {
    if (!startNode) return;
    state.type = 'all';
    state.query = '';
    search.value = '';
    typeFilter.value = 'all';
    selectNode(startNode, false);
    viewport.k = Math.max(viewport.k, 1.05);
    viewport.x = width / 2 - startNode.x * viewport.k;
    viewport.y = height / 2 - startNode.y * viewport.k;
    wake(0.65);
  }

  function updateZoomReadout() {
    zoomReadout.textContent = Math.round(viewport.k * 100) + '%';
  }

  function wake(strength) {
    alpha = Math.max(alpha, strength);
    if (!raf) raf = requestAnimationFrame(frame);
  }

  function frame() {
    raf = 0;
    layout();
    draw();
    alpha *= draggingNode ? 0.98 : 0.94;
    if (alpha > 0.015 || draggingNode) {
      raf = requestAnimationFrame(frame);
    }
  }

  window.addEventListener('resize', () => {
    wake(0.6);
  });
  fitToView();
  selectNode(startNode, false);
  wake(1);
})();`;
}

function writeOutput(graph, outDir) {
  fs.mkdirSync(outDir, { recursive: true });
  const htmlFile = path.join(outDir, 'context-graph.html');
  const jsFile = path.join(outDir, 'context-graph.js');
  fs.writeFileSync(htmlFile, htmlTemplate(graph.meta.title));
  fs.writeFileSync(jsFile, jsTemplate(graph));
  return { htmlFile, jsFile };
}

function main() {
  const args = parseArgs(process.argv.slice(2));
  const graph = makeGraph(args.root, args.title);
  const output = writeOutput(graph, args.out);

  console.log(`context graph exported`);
  console.log(`html: ${output.htmlFile}`);
  console.log(`js: ${output.jsFile}`);
  console.log(`nodes: ${graph.nodes.length}`);
  console.log(`edges: ${graph.edges.length}`);
}

try {
  main();
} catch (error) {
  console.error(`icontext-visualize: ${error.message}`);
  process.exit(1);
}
