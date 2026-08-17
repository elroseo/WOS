---
tags:
  - splunk
  - spl
  - beginner
  - cheatsheet
audience: beginner
updated: 2026-08-17
---

# Splunk Basics Cheatsheet

## What Splunk does

Splunk helps you search and analyze machine data such as application logs, errors, requests, and system events. You search this data with **SPL** (Search Processing Language).

Think of a Splunk search as a pipeline:

```spl
find events
| filter or organize them
| calculate a result
```

Each pipe (`|`) sends the current results to the next command.

## Before you search

Know these three things:

1. **Where to search:** the index, such as `index=my_app`.
2. **When it happened:** set the time range as narrowly as possible.
3. **What identifies it:** an error message, host, user, request ID, service, or other known value.

If you do not know the index, ask the data owner or start from a known dashboard. Avoid beginning with `index=*`, especially over a large time range.

## Run your first search

1. Open the **Search & Reporting** app.
2. Select a time range from the picker, such as **Last 15 minutes**.
3. Enter a search:

```spl
index=my_app error
```

4. Select **Search**.
5. Review several events before adding more commands.

Replace `my_app` with an index you are allowed to search.

### Narrow the results

```spl
index=my_app host="server-01" error
```

```spl
index=my_app service="api" status=500
```

```spl
index=my_app "connection timed out"
```

- Use quotes for an exact phrase.
- Use `field=value` when a field is available.
- Add more terms to make the search narrower.
- SPL keywords such as `AND`, `OR`, and `NOT` should be uppercase.

```spl
index=my_app (error OR exception) NOT "known harmless message"
```

## Understand the results

An individual log record is called an **event**. Important parts include:

| Item | Meaning |
| --- | --- |
| `_time` | When the event occurred |
| `host` | The machine or source that produced it |
| `source` | The file, stream, or input it came from |
| `sourcetype` | The format or category of the data |
| `_raw` | The original event text |
| Fields | Extracted name/value pairs such as `status=500` |

Use the fields sidebar to see which fields and values appear in the current results. Field names vary between indexes, so inspect real events instead of guessing.

## Essential beginner commands

### Show a small sample

```spl
index=my_app
| head 20
```

Use this first to understand what the events look like.

### Display selected fields

```spl
index=my_app error
| table _time host service status message
```

`table` makes results easier to read. Missing columns usually mean the field is not present or has a different name.

### Count events

```spl
index=my_app error
| stats count
```

### Count by a field

```spl
index=my_app error
| stats count by host
| sort - count
```

The minus sign sorts from highest to lowest.

### Find the most common values

```spl
index=my_app
| top limit=10 status
```

### Show activity over time

```spl
index=my_app error
| timechart span=5m count
```

Change `5m` to another interval, such as `1m`, `15m`, or `1h`.

### Filter after the first search

```spl
index=my_app
| search status>=500
| table _time host status message
```

Use `search` for straightforward filtering. Use `where` when you need an expression:

```spl
index=my_app
| where duration_ms > 1000
| table _time host duration_ms
```

## Time ranges

The time picker is easiest for a new user. Time can also be included in SPL:

| SPL | Meaning |
| --- | --- |
| `earliest=-15m latest=now` | Last 15 minutes |
| `earliest=-2h latest=now` | Last 2 hours |
| `earliest=-24h latest=now` | Last 24 hours |
| `earliest=-7d@d latest=@d` | Previous seven complete days |

Example:

```spl
index=my_app error earliest=-2h latest=now
```

Always confirm the timezone. A correct search over the wrong time window can look like there is no data.

## A simple troubleshooting workflow

1. **Set a narrow time range.**
2. **Select the correct index.**
3. **Search one known value**, such as an exact error or request ID.
4. **Inspect 10-20 raw events.**
5. **Identify useful fields** from those events.
6. **Group the results** with `stats`, `top`, or `timechart`.
7. **Record the search and time range** before sharing a conclusion.

Example:

```spl
index=my_app "request-123" earliest=-30m latest=now
| table _time host service status message
| sort _time
```

If the first search returns nothing, widen the time slightly and check the spelling, index, timezone, field name, and data retention. No results do not automatically prove that an event did not happen.

## Useful search patterns

### Errors by host

```spl
index=my_app (error OR exception OR failed)
| stats count by host
| sort - count
```

### HTTP status summary

```spl
index=my_app status=*
| stats count by status
| sort - count
```

### Slow events

```spl
index=my_app duration_ms=*
| where duration_ms > 1000
| table _time host duration_ms message
| sort - duration_ms
```

### Unique users or request IDs

```spl
index=my_app
| stats dc(user) as unique_users dc(request_id) as unique_requests
```

`dc()` means distinct count.

## Beginner tips

- Start small: one index, a short time range, and `| head 20`.
- Filter early so Splunk processes less data.
- Prefer exact fields and values over broad keyword searches.
- Inspect `_raw` before assuming what a field means.
- Build the search one pipe at a time and run it after each change.
- Use **Events** to inspect logs, **Statistics** for tables, and **Visualization** for charts.
- Save useful searches with a clear name and description.
- Copy important SPL into investigation notes so someone else can reproduce it.
- Compare unusual results with a normal period before calling them a problem.
- Remove or mask sensitive information before exporting or sharing results.

## Common mistakes

- Searching all indexes over several days.
- Using the wrong timezone or time range.
- Assuming field names are the same in every index.
- Adding many commands before checking sample events.
- Treating event count as proof of customer impact.
- Assuming zero results means nothing happened.
- Sharing a screenshot without the SPL and time range.

## Quick reference

These are complete examples. Replace `my_app` and the example field names with values from your Splunk environment.

| Goal                       | Complete SPL example                                  | What it shows                                  |
| -------------------------- | ----------------------------------------------------- | ---------------------------------------------- |
| Search for a word          | `index=my_app error`                                  | Events containing `error`                      |
| Search for an exact phrase | `index=my_app "connection timed out"`                 | Events containing that exact phrase            |
| Search a field             | `index=my_app status=500`                             | Events whose extracted `status` field is `500` |
| Combine conditions         | `index=my_app (error OR exception) host="server-01"`  | Errors or exceptions from one host             |
| Exclude a value            | `index=my_app error NOT "known harmless message"`     | Error events without the excluded phrase       |
| Limit the time             | `index=my_app earliest=-2h latest=now`                | Events from the last two hours                 |
| Sample events              | `index=my_app \| head 20`                             | The first 20 matching events                   |
| Display selected fields    | `index=my_app \| table _time host status message`     | A readable table containing only those fields  |
| Keep useful fields         | `index=my_app \| fields _time host status message`    | Results with unnecessary fields removed        |
| Count all matches          | `index=my_app error \| stats count`                   | One total event count                          |
| Count by a field           | `index=my_app error \| stats count by host`           | Event count for each host                      |
| Find common values         | `index=my_app \| top limit=10 status`                 | The ten most common status values              |
| Find unusual values        | `index=my_app \| rare limit=10 status`                | The ten least common status values             |
| Trend over time            | `index=my_app error \| timechart span=5m count`       | Error counts in five-minute buckets            |
| Sort highest first         | `index=my_app \| stats count by host \| sort - count` | Hosts ordered from most events to least        |
| Remove duplicates          | `index=my_app \| dedup request_id`                    | One event for each request ID                  |
| Show slow events           | `index=my_app \| where duration_ms > 1000`            | Events whose duration exceeds one second       |
| Rename a result            | `index=my_app \| stats count as total_events`         | A count labeled `total_events`                 |
| Count unique values        | `index=my_app \| stats dc(user) as unique_users`      | Number of distinct users                       |

## External references

This guide draws on Splunk's official introductory search material and command reference:

- [Splunk Search Tutorial](https://help.splunk.com/en/splunk-enterprise/search/search-tutorial/10.0)
- [Splunk Search Manual](https://help.splunk.com/en/splunk-enterprise/search/search-manual/10.0)
- [Splunk SPL Search Reference](https://help.splunk.com/en/splunk-enterprise/search/spl-search-reference/10.0)
- [Splunk Search Reference: time modifiers](https://docs.splunk.com/Documentation/Splunk/latest/SearchReference/SearchTimeModifiers)
- [Splunk Search Reference: stats](https://docs.splunk.com/Documentation/Splunk/latest/SearchReference/Stats)
