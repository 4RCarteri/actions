# SQLFluff Lint and Fix Action

This composite action runs lint and fix on SQL files using [`@yu-iskw/action-sqlfluff`](https://github.com/yu-iskw/action-sqlfluff). It can be used in any repository.

## How to use

Add the following to your workflow:

```yaml
jobs:
  lint_fix_sql:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: 4RCarteri/actions/sql-lint-fix@main
        with:
          paths: '**/*.sql'      # Optional: SQL file paths
          dialect: 'postgres'    # Optional: SQL dialect
```

- `paths`: Paths to SQL files (default: `**/*.sql`)
- `dialect`: SQL dialect (default: `ansi`)
- `sqlfluff_version`: sqlfluff version (default: latest)

## Output

- `lint-result`: Lint result, useful for logs and reports.

---
