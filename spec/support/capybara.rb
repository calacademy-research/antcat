# frozen_string_literal: true

# `js_errors: true`: an uncaught JavaScript exception (including an unhandled promise rejection)
# in the page fails the spec with `Ferrum::JavaScriptError`. With `false`, broken JavaScript went
# unnoticed as long as the page still rendered (this is how a jQuery upgrade on AntWeb silently broke
# its header search autocomplete). See also `spec/support/javascript_errors.rb`.
Capybara.register_driver(:cuprite) do |app|
  Capybara::Cuprite::Driver.new(app, js_errors: true, window_size: [1200, 800], process_timeout: 30)
end
Capybara.javascript_driver = :cuprite
Capybara.default_max_wait_time = 5
Capybara.default_selector = :css

Capybara.save_path = './tmp/capybara'
Capybara::Screenshot.prune_strategy = :keep_last_run

Capybara.add_selector(:testid) do
  css { |testid| "*[data-testid=#{testid}]" }
end
