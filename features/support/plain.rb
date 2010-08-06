# truncate your tables here if you are using the same database as selenium, since selenium doesn't use transactional fixtures
Cucumber::Rails::World.use_transactional_fixtures = true
