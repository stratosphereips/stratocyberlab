// Run after installing frontend dependencies: node --test tests/test_assistant_markdown.mjs
import assert from 'node:assert/strict';
import test from 'node:test';
import { JSDOM } from '../dashboard/client/node_modules/jsdom/lib/api.js';

// Give the production sanitizer a DOM; scripts and external resources stay disabled.
const dom = new JSDOM('');
globalThis.window = dom.window;
const { renderAssistantMarkdown } = await import('../dashboard/client/src/assistantMarkdown.js');

function render(content) {
  const container = dom.window.document.createElement('div');
  container.innerHTML = renderAssistantMarkdown(content);
  return container;
}

test('preserves ordinary Markdown, tables, images and safe links', () => {
  const result = render('# Hint\n\n**Check** *DNS*.\n\n- First step\n\n'
    + '| Port | Service |\n| --- | --- |\n| 53 | DNS |\n\n'
    + '[Documentation](https://example.test/docs)\n\n![Diagram](https://example.test/image.png)');
  assert.equal(result.querySelector('h1').textContent, 'Hint');
  assert.equal(result.querySelector('strong').textContent, 'Check');
  assert.equal(result.querySelector('em').textContent, 'DNS');
  assert.equal(result.querySelector('li').textContent, 'First step');
  assert.equal(result.querySelector('td').textContent, '53');
  assert.equal(result.querySelector('a').getAttribute('href'), 'https://example.test/docs');
  assert.equal(result.querySelector('img').getAttribute('alt'), 'Diagram');
});

test('removes event handlers from model-supplied HTML', () => {
  const result = render('<img src="x" onerror="alert(1)"><a href="/docs" onclick="alert(2)">link</a>');
  assert.ok(result.querySelector('img'));
  assert.equal(result.querySelector('[onerror], [onclick]'), null);
});

test('removes scripts, embedded documents, SVG, MathML and forms', () => {
  const result = render('<script>alert(1)</script><iframe srcdoc="bad"></iframe>'
    + '<svg onload="alert(2)"><circle /></svg><math><mi>x</mi></math>'
    + '<form action="/api/state/reset"><input><button>Reset</button></form>'
    + '<object data="/api/state/reset"></object><embed src="/api/state/reset">');
  assert.equal(result.querySelector('script, iframe, svg, math, form, input, button, object, embed'), null);
});

test('removes unsafe URLs including entity-obfuscated JavaScript', () => {
  const result = render('[bad](javascript:alert%281%29)\n\n'
    + '<a href="jav&#x61;script:alert(1)">obfuscated</a>'
    + '<a href="data:text/html,bad">data</a><a href="vbscript:bad">vb</a>');
  assert.equal(result.querySelectorAll('a').length, 4);
  for (const link of result.querySelectorAll('a')) {
    assert.equal(link.hasAttribute('href'), false);
  }
});

test('removes styles and clobbering attributes while preserving educational code as text', () => {
  const result = render('<p id="app" name="location" style="position:fixed" data-action="reset">Hint</p>'
    + '\n\n```html\n<img src=x onerror="alert(1)">\n```');
  assert.equal(result.querySelector('[id], [name], [style], [data-action]'), null);
  assert.equal(result.querySelector('pre code').textContent, '<img src=x onerror="alert(1)">\n');
  assert.equal(result.querySelector('img'), null);
});
