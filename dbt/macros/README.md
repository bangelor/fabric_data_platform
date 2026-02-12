# dbt Macros

This directory contains custom dbt macros for the Fabric Data Platform project.

## Available Macros

### `drop_old_models()`

**Purpose:** Drops models and schemas that have been removed from the dbt project to prevent orphaned database objects.

**Usage:**
```bash
dbt run-operation drop_old_models
```

**When to use:**
- After restructuring your dbt project (e.g., renaming layers)
- When removing deprecated models
- During major refactoring

**How it works:**
- Executes `DROP IF EXISTS` statements for specified objects
- Safe to run multiple times (idempotent)
- Runs automatically in CI/CD before model builds

**Maintenance:**
When you remove models from your project, add their cleanup SQL to this macro:
1. Edit `macros/drop_old_models.sql`
2. Add `DROP` statements to the `drop_queries` array
3. Commit and push - the CI/CD will clean up automatically

**Example:**
```sql
{% set drop_queries = drop_queries + [
    "DROP TABLE IF EXISTS old_schema.old_table",
    "DROP SCHEMA IF EXISTS old_schema"
] %}
```

---

### `generate_schema_name()`

**Purpose:** Customizes how dbt generates schema names for models.

**Behavior:**
- Returns the custom schema name directly (e.g., `bronze`, `silver`, `gold`)
- Prevents dbt's default behavior of concatenating target schema with custom schema

**Default dbt behavior:** `dbo` + `staging` = `dbo_staging`  
**Custom behavior:** `staging` → `staging`

**Configuration:**
Automatically applied to all models. Schema names are configured in `dbt_project.yml`:
```yaml
models:
  fabric_data_platform:
    bronze:
      +schema: bronze
```

---

## Best Practices

1. **Keep macros simple** - Each macro should do one thing well
2. **Add comments** - Use Jinja comments `{# #}` to document macro logic
3. **Test locally** - Run `dbt run-operation <macro_name>` to test before committing
4. **Use logging** - Use `{% do log() %}` to provide visibility into macro execution
5. **Handle errors gracefully** - Use `IF EXISTS` for safe cleanup operations

## Creating New Macros

To create a new macro:

1. Create a new `.sql` file in this directory
2. Define your macro using:
   ```sql
   {% macro macro_name(param1, param2) %}
       -- Your code here
   {% endmacro %}
   ```
3. Call it with:
   ```bash
   dbt run-operation macro_name --args '{"param1": "value1"}'
   ```
4. Document it in this README

## Reference

- [dbt Macro Documentation](https://docs.getdbt.com/docs/building-a-dbt-project/jinja-macros)
- [dbt run-operation command](https://docs.getdbt.com/reference/commands/run-operation)
