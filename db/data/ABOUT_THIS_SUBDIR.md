This subdir contains data migrations.

To create a new data migration:
```sh
bundle exec rails g data_migration populate_important_things
```

To run them:
```sh
bundle exec rake data:migrate
```
