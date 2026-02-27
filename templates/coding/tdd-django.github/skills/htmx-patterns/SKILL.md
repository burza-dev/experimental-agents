---
name: htmx-patterns
description: HTMX integration patterns with Django for dynamic updates without full page reloads. Use when implementing dynamic UI behavior, partial page updates, or AJAX-like functionality.
---

# HTMX Patterns with Django

## Core Concepts
- HTMX extends HTML with `hx-*` attributes for AJAX behavior
- No JavaScript needed for most dynamic updates
- Works seamlessly with Django templates

## Common Patterns

### Partial Updates
```html
<button hx-get="/api/refresh" hx-target="#content" hx-swap="innerHTML">
    Refresh
</button>
<div id="content">...</div>
```

### Form Submission
```html
<form hx-post="/api/submit" hx-target="#result" hx-swap="outerHTML">
    {% csrf_token %}
    <input name="data" />
    <button type="submit">Submit</button>
</form>
```

### Django View for HTMX
```python
async def partial_view(request: HttpRequest) -> HttpResponse:
    """Return partial HTML for HTMX requests."""
    context = await get_context_async()
    return render(request, "partials/content.html", context)
```

### Detect HTMX Request
```python
def is_htmx(request: HttpRequest) -> bool:
    return request.headers.get("HX-Request") == "true"
```
