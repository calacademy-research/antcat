# frozen_string_literal: true

Capybara.register_driver :apparition do |app|
  Capybara::Apparition::Driver.new(
    app,
    js_errors: false,
    browser_options: [
      :no_sandbox # For Docker, see https://stackoverflow.com/a/57508822.
    ]
  )
end

Capybara.javascript_driver = :apparition
Capybara.default_max_wait_time = 5
Capybara.default_selector = :css

Capybara.save_path = './tmp/capybara'
Capybara::Screenshot.prune_strategy = :keep_last_run

Capybara.add_selector(:testid) do
  css { |testid| "*[data-testid=#{testid}]" }
end
