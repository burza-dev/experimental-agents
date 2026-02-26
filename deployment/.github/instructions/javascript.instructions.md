---
applyTo: "**/static/**/*.js,**/*.js"
---

# JavaScript rules

## Style
- Use modern ES6+ syntax
- Use `const` by default, `let` when reassignment needed
- Never use `var`
- Use arrow functions for callbacks
- Use template literals for string interpolation

## Accessibility
- Add ARIA attributes where needed
- Ensure keyboard navigation works
- Manage focus appropriately
- Provide screen reader announcements for dynamic content

## HTMX is Preferred
**Use HTMX instead of custom JavaScript** for most dynamic functionality:
- Prefer `hx-*` attributes over JavaScript event handlers
- HTMX handles AJAX, loading states, and DOM updates automatically
- Only write custom JS when HTMX cannot achieve the desired behavior

## HTMX integration
- Use `hx-*` attributes for AJAX interactions
- Handle loading states with `htmx-request` class
- Use `hx-swap` appropriately
- Provide fallbacks for non-JS users

## Bootstrap JavaScript
- Use Bootstrap's JavaScript API correctly
- Initialize components with data attributes when possible
- Use events for custom behavior

## DOM manipulation
- Use `document.querySelector` / `querySelectorAll`
- Prefer event delegation for dynamic content
- Clean up event listeners when elements are removed

## Forbidden
- `eval()` or `Function()` constructor
- Global variables (use modules or IIFE)
- Inline event handlers in HTML (use addEventListener)
- Blocking operations in event handlers
- Console.log statements in production code
