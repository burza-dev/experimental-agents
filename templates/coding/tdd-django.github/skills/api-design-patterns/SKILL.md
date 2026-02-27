---
name: api-design-patterns
description: REST API design patterns for Django. Apply when implementing HTTP endpoints, request/response handling, or API versioning.
---

# REST API Design Patterns

## Async View Patterns
All API views must be async:

```python
from django.http import HttpRequest, JsonResponse

async def api_list_tasks(request: HttpRequest) -> JsonResponse:
    """List all tasks (async)."""
    tasks = [task async for task in Task.objects.all()]
    return JsonResponse({"tasks": [t.to_dict() for t in tasks]})
```

## Request Validation
Use Pydantic for request validation:

```python
from pydantic import BaseModel, Field
import json

class CreateTaskRequest(BaseModel):
    title: str = Field(..., min_length=1, max_length=200)
    priority: int = Field(default=1, ge=1, le=5)

async def api_create_task(request: HttpRequest) -> JsonResponse:
    """Create a new task."""
    try:
        data = CreateTaskRequest.model_validate_json(request.body)
    except ValidationError as e:
        return JsonResponse({"errors": e.errors()}, status=400)
    
    task = await Task.objects.acreate(
        title=data.title,
        priority=data.priority,
    )
    return JsonResponse({"task": task.to_dict()}, status=201)
```

## Response Format
Consistent JSON response structure:

```python
# Success responses
{"data": {...}}           # Single object
{"items": [...]}          # List of objects
{"items": [...], "total": 100, "page": 1}  # Paginated

# Error responses
{"error": "Not found"}    # Simple error
{"errors": [...]}         # Validation errors with details
```

## HTTP Method Handling
```python
async def api_task(request: HttpRequest, task_id: int) -> JsonResponse:
    """Handle task CRUD operations."""
    match request.method:
        case "GET":
            return await _get_task(task_id)
        case "PUT":
            return await _update_task(request, task_id)
        case "DELETE":
            return await _delete_task(task_id)
        case _:
            return JsonResponse({"error": "Method not allowed"}, status=405)
```

## URL Patterns
RESTful URL design:

```python
# urls.py
urlpatterns = [
    path("api/v1/tasks/", views.api_list_tasks),         # GET (list), POST (create)
    path("api/v1/tasks/<int:id>/", views.api_task),      # GET, PUT, DELETE
    path("api/v1/tasks/<int:id>/comments/", views.api_task_comments),
]
```

## Pagination
```python
from django.core.paginator import Paginator

async def api_list_paginated(request: HttpRequest) -> JsonResponse:
    page = int(request.GET.get("page", 1))
    per_page = int(request.GET.get("per_page", 20))
    
    tasks = await Task.objects.all().acount()
    paginator = Paginator(Task.objects.all(), per_page)
    page_obj = await paginator.aget_page(page)
    
    return JsonResponse({
        "items": [t.to_dict() async for t in page_obj],
        "total": tasks,
        "page": page,
        "per_page": per_page,
    })
```

## Error Handling
```python
from django.http import Http404

async def api_get_task(request: HttpRequest, task_id: int) -> JsonResponse:
    task = await Task.objects.filter(id=task_id).afirst()
    if not task:
        return JsonResponse({"error": "Task not found"}, status=404)
    return JsonResponse({"data": task.to_dict()})
```

## HTMX Partial Responses
For HTMX requests, return HTML partials:

```python
async def api_or_partial(request: HttpRequest) -> HttpResponse:
    data = await get_data()
    
    if request.headers.get("HX-Request"):
        return render(request, "partials/data.html", {"data": data})
    return JsonResponse({"data": data})
```
