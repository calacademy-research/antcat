# coding: UTF-8
Cucumber::Rails::World.use_transactional_fixtures = false

Capybara.default_driver = :selenium

Before do
  # truncate your tables here, since you can't use transactional fixtures*
end
