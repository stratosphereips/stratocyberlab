export const TERMINAL_CONTEXT_LINES = 100;
export const TERMINAL_CONTEXT_BYTES = 10000;

const encoder = new TextEncoder();

export function contextStats(context) {
  return {
    lines: context.text.split('\n').length,
    bytes: encoder.encode(context.text).length,
  };
}

// Read rendered cells, not raw SSH traffic. Ignore viewportY: scrolling back
// should not change which output accompanies a new question.
export function captureTerminalContext(terminal) {
  if (!terminal) return null;
  const buffer = terminal.buffer.active;
  let text = '';
  let lines = 0;
  let nextIsWrapped = false;
  let truncated = false;

  for (let index = buffer.length - 1; index >= 0; index--) {
    const line = buffer.getLine(index);
    if (!line) continue;
    const row = line.translateToString(!nextIsWrapped, 0, terminal.cols);
    // The unused bottom of the screen is not terminal output.
    if (lines === 0 && !row) continue;
    const newLine = lines > 0 && !nextIsWrapped;
    if (newLine && lines === TERMINAL_CONTEXT_LINES) {
      truncated = true;
      break;
    }
    text = row + (newLine ? '\n' : '') + text;
    if (lines === 0 || newLine) lines++;
    const bytes = encoder.encode(text);
    if (bytes.length > TERMINAL_CONTEXT_BYTES) {
      let start = bytes.length - TERMINAL_CONTEXT_BYTES;
      // Move past any continuation bytes to keep the suffix valid UTF-8.
      while ((bytes[start] & 0xc0) === 0x80) start++;
      text = new TextDecoder().decode(bytes.subarray(start));
      truncated = true;
      break;
    }
    nextIsWrapped = line.isWrapped;
    if (index === 0 && line.isWrapped) truncated = true;
  }

  return text ? { text, captured_at: new Date().toISOString(), truncated } : null;
}
