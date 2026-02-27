---
name: django-migrations
description: Django migration patterns with async ORM considerations. Apply when creating or modifying database models.
---

# Django Migration Patterns

## Creating Migrations
Always generate migrations with descriptive names:

```bash
uv run python manage.py makemigrations --name add_user_preferences
```

## Async Model Methods
When defining model methods, use async:

```python
from django.db import models

class Task(models.Model):
    title = models.CharField(max_length=200)
    status = models.CharField(max_length=20, default="pending")
    
    async def mark_complete(self) -> None:
        """Mark task as complete (async)."""
        self.status = "complete"
        await self.asave()
    
    @classmethod
    async def get_pending(cls) -> list["Task"]:
        """Get all pending tasks."""
        return [task async for task in cls.objects.filter(status="pending")]
```

## Data Migrations
For complex data migrations, use RunPython:

```python
from django.db import migrations

async def migrate_data_forward(apps, schema_editor):
    Task = apps.get_model("tasks", "Task")
    async for task in Task.objects.filter(old_field__isnull=False):
        task.new_field = transform(task.old_field)
        await task.asave()

class Migration(migrations.Migration):
    dependencies = [("tasks", "0001_initial")]
    
    operations = [
        migrations.RunPython(migrate_data_forward, migrations.RunPython.noop),
    ]
```

## Reversible Migrations
Always provide reverse operations:

```python
async def forward(apps, schema_editor):
    # ... forward migration
    
async def backward(apps, schema_editor):
    # ... reverse migration

operations = [
    migrations.RunPython(forward, backward),
]
```

## Testing Migrations
Test migrations don't break:

```python
import pytest
from django.core.management import call_command

@pytest.mark.django_db
def test_migrations_complete() -> None:
    """Test all migrations can be applied."""
    call_command("migrate", "--check")
```

## Migration Squashing
For production, squash old migrations:

```bash
uv run python manage.py squashmigrations myapp 0001 0050
```

## Async Bulk Operations
Use async bulk operations in migrations:

```python
async def populate_defaults(apps, schema_editor):
    Setting = apps.get_model("config", "Setting")
    defaults = [
        Setting(key="theme", value="light"),
        Setting(key="language", value="en"),
    ]
    await Setting.objects.abulk_create(defaults)
```
