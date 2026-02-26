---
applyTo: "**/templates/**/*.html,**/*.html"
---

# HTML/Template rules

## Framework
- Use Bootstrap 5.x+ for styling
- Use Django template syntax
- Use semantic HTML5 elements
- Use HTMX for dynamic updates (preferred over custom JavaScript)

## Template Organization
```
templates/
├── pages/        # Full page templates
├── partials/     # Reusable sections (collections of components)
├── components/   # Smallest reusable units
└── base.html     # Base template
```

## Accessibility (WCAG 2.1 AA)
- All interactive elements must have accessible names
- Use proper heading hierarchy (h1 → h2 → h3)
- Provide alt text for all images
- Ensure color contrast meets minimum requirements
- Ensure keyboard navigation works
- Associate labels with form inputs

## Bootstrap usage
- Prefer Bootstrap utilities over custom CSS
- Use responsive breakpoints appropriately
- Use the grid system for layouts
- Use Bootstrap components correctly

## Structure
```html
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>{% block title %}{ProjectName}{% endblock %}</title>
</head>
<body>
    <main role="main">
        {% block content %}{% endblock %}
    </main>
</body>
</html>
```

## Forms
- Always use `<label>` elements with `for` attribute
- Mark required fields with `required` attribute
- Provide clear validation feedback
- Use appropriate input types (email, tel, etc.)

## Django templates
- Use `{% load static %}` for static files
- Use `{% url %}` for links
- Use `{% csrf_token %}` in POST forms
- Escape user content by default (Django handles this)

## HTMX Integration
- Use `hx-*` attributes for AJAX behavior without JavaScript
- Use `hx-get`, `hx-post` for requests
- Use `hx-target` to specify update target
- Use `hx-swap` to control content replacement (innerHTML, outerHTML, etc.)
- Always include `{% csrf_token %}` for POST requests
- Return partial HTML templates for HTMX endpoints

### HTMX Example
```html
<button hx-get="/api/refresh" hx-target="#content" hx-swap="innerHTML">
    Refresh
</button>
<div id="content">...</div>
```

## Forbidden
- Inline styles (use Bootstrap classes or CSS files)
- Deprecated HTML elements
- Missing alt text on images
- Forms without CSRF protection
- Tables for layout (use grid)
- Custom JavaScript when HTMX can achieve the same result
