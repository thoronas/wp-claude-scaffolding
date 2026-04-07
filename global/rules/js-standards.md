---
paths:
  - "plugins/**/assets/**/*.js"
  - "plugins/**/blocks/**/*.js"
  - "plugins/**/blocks/**/*.jsx"
  - "themes/**/assets/**/*.js"
  - "themes/**/blocks/**/*.js"
  - "themes/**/blocks/**/*.jsx"
---

When writing or editing JavaScript files:

- Use ES6+ syntax (const/let, arrow functions, destructuring, template literals)
- Import WordPress packages from `@wordpress/*` not `wp.*` globals (in block context)
- Use `useBlockProps()` on the outermost wrapper in every block edit/save
- React hooks: follow rules of hooks (no conditional hooks, no hooks in loops)
- Error boundaries around dynamic block content
- No jQuery unless interfacing with legacy WordPress admin JS
- If `npm run lint` is available, run it before finalizing any JS file
