{% macro drop_old_models() %}
    {# 
        Generic macro to drop any tables or views in bronze/silver/gold schemas
        that are not present in the current dbt project.
        
        This prevents orphaned objects from accumulating when models are removed or renamed.
        
        Usage: dbt run-operation drop_old_models
    #}
    
    {% set managed_schemas = ['bronze', 'silver', 'gold'] %}
    
    {% do log("=" * 80, info=True) %}
    {% do log("Scanning database for orphaned objects...", info=True) %}
    {% do log("=" * 80, info=True) %}
    
    {# Get all current dbt models from the project #}
    {% set dbt_models = {} %}
    {% for node in graph.nodes.values() %}
        {% if node.resource_type == 'model' %}
            {% set schema = node.schema %}
            {% set name = node.name %}
            {% set materialization = node.config.materialized %}
            {% do dbt_models.update({(schema ~ '.' ~ name): {'schema': schema, 'name': name, 'type': materialization}}) %}
        {% endif %}
    {% endfor %}
    
    {% do log("Found " ~ dbt_models|length ~ " models in dbt project", info=True) %}
    
    {# Query database for existing tables and views in managed schemas #}
    {% set query %}
        SELECT 
            TABLE_SCHEMA as schema_name,
            TABLE_NAME as object_name,
            TABLE_TYPE as object_type
        FROM INFORMATION_SCHEMA.TABLES
        WHERE TABLE_SCHEMA IN ({{ "'" + managed_schemas|join("','") + "'" }})
        ORDER BY TABLE_SCHEMA, TABLE_NAME
    {% endset %}
    
    {% set results = run_query(query) %}
    
    {% if execute %}
        {% set db_objects = {} %}
        {% for row in results %}
            {% set key = row[0] ~ '.' ~ row[1] %}
            {% do db_objects.update({key: {'schema': row[0], 'name': row[1], 'type': row[2]}}) %}
        {% endfor %}
        
        {% do log("Found " ~ db_objects|length ~ " objects in database", info=True) %}
        {% do log("", info=True) %}
        
        {# Find orphaned objects (in DB but not in dbt project) #}
        {% set objects_to_drop = [] %}
        {% for key, obj in db_objects.items() %}
            {% if key not in dbt_models %}
                {% do objects_to_drop.append(obj) %}
            {% endif %}
        {% endfor %}
        
        {% if objects_to_drop|length > 0 %}
            {% do log("Found " ~ objects_to_drop|length ~ " orphaned objects to drop:", info=True) %}
            
            {# Drop orphaned objects #}
            {% for obj in objects_to_drop %}
                {% set drop_type = 'TABLE' if obj.type == 'BASE TABLE' else 'VIEW' %}
                {% set drop_sql = "DROP " ~ drop_type ~ " IF EXISTS [" ~ obj.schema ~ "].[" ~ obj.name ~ "]" %}
                {% do log("  - Dropping " ~ drop_type ~ ": " ~ obj.schema ~ "." ~ obj.name, info=True) %}
                {% do run_query(drop_sql) %}
            {% endfor %}
            
            {% do log("", info=True) %}
            {% do log("✓ Dropped " ~ objects_to_drop|length ~ " orphaned objects", info=True) %}
        {% else %}
            {% do log("✓ No orphaned objects found - database is clean!", info=True) %}
        {% endif %}
        
        {# Drop empty schemas #}
        {% do log("", info=True) %}
        {% do log("=" * 80, info=True) %}
        {% do log("✓ Cleanup complete!", info=True) %}
        {% do log("=" * 80, info=True) %}
    {% endif %}
{% endmacro %}
