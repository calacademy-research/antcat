# AntCat function catalog

`routes.tsv` has one row per route of the app (290 on 2026-11-13: 288 routes, the mounted API docs engine and the assets route): what it is for, who may use it, whether it stays,
and the spec that covers it. `spec/catalog/routes_catalog_spec.rb` fails when a route has no row or a row has no route,
so a new route cannot be added without saying what it is for. Its failure message prints the missing rows, ready to
paste. Tab-separated; open it in a spreadsheet or read it on GitHub.

| Column | Meaning |
|---|---|
| verb, path, action, name | the route as Rails has it (`bin/rails routes`) |
| who | the least a visitor must be: `public` (anyone), `user` (signed in), `helper`, `editor`, `superadmin`, `api` (the JSON API, with or without a key), `system` (not for people: browser reports, gem routes, development-only previews). Read from the controller's `before_action` checks |
| purpose | what the route is for, in a few words |
| status | `keep`, `check` (to decide), `remove` |
| test | a spec file for the route's controller or a request or feature spec that names it; blank = none found. It says such a file exists, not that this exact route is exercised (a controller spec calls the action directly, past the routing) |

## Summary (2026-11-13; not checked by the spec, recount when routes change)

| Who | Routes |
|---|---|
| public | 92 |
| user | 20 |
| helper | 59 |
| editor | 63 |
| superadmin | 22 |
| api | 29 |
| system | 5 |

## Decided (2026-11-13, Brian Fisher)

- Removed: the superadmins' "New user" form (`users#new`, `users#create`; its POST reached Devise's sign-up route,
  so it never worked; people sign up themselves and get rights on the edit page), `DevsController` (developer pages
  with no route), and the three Turbo Native routes (`config.turbo.draw_routes = false`; AntCat has no native app).

## Routes without a spec

`/references/latest_additions` and `/*id` (the static pages of the high_voltage gem, the last route). The component previews
(`/rails/view_components`, `/_system_test_entrypoint`) exist only in development and test.

## See also

- `docs/data-model.md`: every table, what one row is and how the tables connect (checked by
  `spec/catalog/data_model_spec.rb`).
- `docs/data-flows.md`: where the data comes from and goes: editing, reading and the API, the nightly export to
  AntWeb, email, backups and deploys.
