# AntCat function catalog

`routes.tsv` has one row per route of the app (294 on 2026-11-13: 293 routes and one mounted engine, the API docs): what it is for, who may use it, whether it stays,
and the spec that covers it. `spec/catalog/routes_catalog_spec.rb` fails when a route has no row or a row has no route,
so a new route cannot be added without saying what it is for. Its failure message prints the missing rows, ready to
paste. Tab-separated; open it in a spreadsheet or read it on GitHub.

| Column | Meaning |
|---|---|
| verb, path, action, name | the route as Rails has it (`bin/rails routes`) |
| who | the least a visitor must be: `public` (anyone), `user` (signed in), `helper`, `editor`, `superadmin`, `api` (the JSON API, with or without a key), `system` (not for people: browser reports, gem routes, development-only previews). Read from the controller's `before_action` checks |
| purpose | what the route is for, in a few words |
| status | `keep`, `check` (to decide), `remove` |
| test | a spec that requests the route or its controller; blank = none found |

## Summary (2026-11-13)

| Who | Routes |
|---|---|
| public | 92 |
| user | 20 |
| helper | 59 |
| editor | 63 |
| superadmin | 24 |
| api | 29 |
| system | 7 |

## To decide (status `check`)

- `/recede_historical_location`, `/resume_historical_location`, `/refresh_historical_location`
  (`turbo/native/navigation`): added by the turbo-rails gem for Turbo Native apps. AntCat has no native app. They do no
  harm; they can be dropped by not loading the gem's route file.

- `DevsController` (`app/controllers/devs_controller.rb`, developer pages of the pickers and styles) has views but
  no route, so it is not in this list and cannot be reached: a candidate for removal.

## Routes without a spec

`/references/latest_additions`, the three Turbo Native routes above, and `/*id` (the static pages of the high_voltage gem, the last route). The component previews
(`/rails/view_components`, `/_system_test_entrypoint`) exist only in development and test.

## See also

- `docs/data-model.md`: every table, what one row is and how the tables connect (checked by
  `spec/catalog/data_model_spec.rb`).
- `docs/data-flows.md`: where the data comes from and goes: editing, reading and the API, the nightly export to
  AntWeb, email, backups and deploys.
