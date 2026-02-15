# ADR 002: Character Factions

One important world-building element of a role-playing game is characters' factions. 
In some scenarios, they are sides of a conflict, in others - different countries, planets or races 
in the state of political rivalry. Those big factions are usually further divided into smaller
factions: Great Houses have lesser houses, the gnomes can be deep gnomes and surface gnomes.

So, the factions are best represented by a tree with multiple roots, and each character belongs not
only to one specific node to that tree, but to that node and all its parents nodes. It is an important
consideration, because we need to consider how to build a query to find all the characters of the root faction
as well as how to find all the characters of a specific subfaction. Both need to be fast and simple.

The solution cuento uses is to create a record for every character-faction pair.

## Example

### Factions Table

| Faction ID | Faction Name    |
|------------|-----------------|
| 1          | Dune            |
| 2          | House Harkonnen |

### Characters Table

| Character ID | Character Name |
|--------------|----------------|
| 1            | Piter de Vries |

### Character-Faction Relationship Table

| Character ID | Faction ID |
|--------------|------------|
| 1            | 1          |
| 1            | 2          |

Now we can find Piter de Vries easily in any faction. 

However, when we build a character list, we want Piter de Vries to present there only once, 
under the lowest level faction. It is done with a `ROW_NUMBER() OVER()` query:

```sql
WITH RankedFactions AS (
    SELECT
        c.id,
        c.name,
        c.avatar,
        f.id as faction_id,
        ROW_NUMBER() OVER(PARTITION BY c.id ORDER BY f.level DESC) as rn
    FROM
        character_base c
    JOIN
        character_faction cf ON c.id = cf.character_id
    JOIN
        factions f ON cf.faction_id = f.id
    WHERE
        c.character_status = 0
)
SELECT id, name, avatar, faction_id FROM RankedFactions WHERE rn = 1
```

This query is suitable for a small site and a small database like MariaDB. If the site were predicted to be
much larger, it would be prudent to choose a different database like Postgres and use `DISTICNT ON`, but that would
mean different server cost.