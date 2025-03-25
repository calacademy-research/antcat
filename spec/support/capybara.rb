# frozen_string_literal: true

Capybara.register_driver(:cuprite) do |app|
  Capybara::Cuprite::Driver.new(app, js_errors: false, window_size: [1200, 800])
end
Capybara.javascript_driver = :cuprite
Capybara.default_max_wait_time = 5
Capybara.default_selector = :css

Capybara.save_path = './tmp/capybara'
Capybara::Screenshot.prune_strategy = :keep_last_run

Capybara.add_selector(:testid) do
  css { |testid| "*[data-testid=#{testid}]" }
end
