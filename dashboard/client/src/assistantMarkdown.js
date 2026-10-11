import DOMPurify from 'dompurify';
import { marked } from 'marked';

// Model output is untrusted. Sanitize the final HTML immediately before rendering.
export function renderAssistantMarkdown(content) {
  return DOMPurify.sanitize(marked.parse(content), {
    ALLOWED_TAGS: [
      'p', 'br', 'hr', 'h1', 'h2', 'h3', 'h4', 'h5', 'h6',
      'blockquote', 'ul', 'ol', 'li', 'pre', 'code', 'em', 'strong', 'del',
      'a', 'img', 'table', 'thead', 'tbody', 'tr', 'th', 'td',
      'details', 'summary', 'kbd', 'sub', 'sup',
    ],
    ALLOWED_ATTR: ['href', 'title', 'src', 'alt', 'start', 'align'],
    ALLOW_DATA_ATTR: false,
    ALLOW_ARIA_ATTR: false,
  });
}
