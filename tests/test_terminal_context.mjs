// Run: node --test tests/test_terminal_context.mjs
import assert from 'node:assert/strict';
import { readFileSync } from 'node:fs';
import test from 'node:test';

// The client uses bundler ES modules without package.json type:module.
const source = readFileSync(new URL('../dashboard/client/src/terminalContext.js', import.meta.url), 'utf8');
const { captureTerminalContext, contextStats } = await import(`data:text/javascript;base64,${Buffer.from(source).toString('base64')}`);

function terminal(rows) {
  return {
    cols: 20000,
    buffer: {
      active: {
        length: rows.length,
        viewportY: 0,
        getLine(index) {
          const row = rows[index];
          const text = typeof row === 'string' ? row : row.text;
          return {
            isWrapped: row.wrapped || false,
            translateToString: trimRight => trimRight ? text.replace(/ +$/, '') : text,
          };
        },
      },
    },
  };
}

test('latest 100 logical lines regardless of viewport, omitting unused screen rows', () => {
  const rows = Array.from({ length: 150 }, (_, i) => `output ${i}`);
  const snapshot = captureTerminalContext(terminal([...rows, '', '   ']));
  assert.equal(snapshot.text, rows.slice(-100).join('\n'));
  assert.equal(contextStats(snapshot).lines, 100);
  assert.equal(snapshot.truncated, true);
  assert.ok(Number.isFinite(Date.parse(snapshot.captured_at)));
});

test('wrapped rows rejoin, preserving indentation and spaces within logical lines', () => {
  const snapshot = captureTerminalContext(terminal([
    '  first row  ', { text: 'continues', wrapped: true }, '', '  final line  ', '',
  ]));
  assert.equal(snapshot.text, '  first row  continues\n\n  final line');
  assert.equal(snapshot.truncated, false);
});

test('byte limit keeps newest valid UTF-8 even within one very long line', () => {
  const text = 'old text' + '😀'.repeat(3000) + 'end';
  const snapshot = captureTerminalContext(terminal([text]));
  assert.equal(snapshot.text, '😀'.repeat(2499) + 'end');
  assert.equal(contextStats(snapshot).bytes, 9999);
  assert.equal(snapshot.truncated, true);
  assert.ok(!snapshot.text.includes('\ufffd'));
});

test('exact boundaries are not marked truncated; wrapped screen rows count as one line', () => {
  assert.equal(captureTerminalContext(terminal(['x'.repeat(10000)])).truncated, false);
  const rows = Array.from({ length: 200 }, (_, i) => ({text: 'x', wrapped: i % 2 === 1}));
  const snapshot = captureTerminalContext(terminal(rows));
  assert.equal(snapshot.text, Array(100).fill('xx').join('\n'));
  assert.equal(snapshot.truncated, false);
});

test('empty or uninitialized terminal has no attachment', () => {
  assert.equal(captureTerminalContext(null), null);
  assert.equal(captureTerminalContext(terminal(['', '   '])), null);
});

test('active alternate screen and snapshots do not retain later changes', () => {
  const rows = ['top - process list', '  process 42'];
  const term = terminal(rows);
  term.buffer.normal = terminal(['old shell output']).buffer.active;
  term.buffer.active.type = 'alternate';
  const snapshot = captureTerminalContext(term);
  rows[1] = '  changed process';
  assert.equal(snapshot.text, 'top - process list\n  process 42');
  assert.equal(captureTerminalContext(term).text, 'top - process list\n  changed process');
});
