# ADR 001: Custom Fields and Their Types

The hobby project I am currently working on is a small role-playing play-by-post platform, and it heavily relies on entities with customizable fields. On one site, a character may have three additional fields like "Biography", "Age" and "Race", and, on another, a dozen fields for different stats like STR and DEX. It all depends on the game masters' decision and the logic of the game. The platform's responsibility is to provide them a mechanism to have it exactly the way they want it.

So, what do we need to bake custom fields into a platform? Three things.

### 1. An Admin Template

A generic structure of any custom field. In my case, it looks like this:

```go
type CustomFieldConfig struct {
	MachineFieldName string `json:"machine_field_name"`
	HumanFieldName   string `json:"human_field_name"`
	FieldType        string `json:"field_type"`
	ContentFieldType string `json:"content_field_type"`
	Order            int    `json:"order"`
}
```

You may notice that this structure does not have a value field. This is because this structure is strictly for rendering the form fields. This is for creating a template, not for filling it with actual data.

### 2. A Table or Tables to Store the Data

I have opted for two tables: one is a classical Entity-Attribute-Value - stores each field value in a row, and its structure is static. The other table is dynamic, it is altered on the flight according to the changing custom fields, and it represents a flattened version of an entity.

Each entity has its own "flattened" table. It is updated using database triggers on insert, update and delete into the EAV table. Those tables are great for joining and queries even without indexes.

Now, altering a table on the flight might seem heavy, but, in reality, it is not. Because the changes happen only when the game masters change a template, there is never any need for a backfill. The only two operations I am are going to perform on these tables are adding a new column with all empty values or removing a column. Both are metadata-only changes and do not lock the table.

### 3. The Correct UI

While in database we, most likely, will store a short text and an image url in the same VARCHAR field, from the UI perspective, those are two completely different things. Thus, you may notice that the template has two type fields: `FieldType` and `ContentFieldType`. The former translates into the database column type, and the latter into specific UI components for rendering the field and later the value.
