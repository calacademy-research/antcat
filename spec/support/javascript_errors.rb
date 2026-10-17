# frozen_string_literal: true

# Helpers for checking that pages run their JavaScript without errors in headless Chrome.
#
# `js_errors: true` (see `spec/support/capybara.rb`) already fails a `:js` spec when the page throws,
# but Ferrum reports the error asynchronously, so an error thrown after the spec's last browser
# command can be missed. `expect_no_js_errors` closes that gap: a collector is installed before any
# page script runs and the spec asserts on what it recorded.
module JavascriptErrorHelpers
  JS_ERROR_COLLECTOR = <<~JS
    (() => {
      if (window.__antcatJsErrors) return
      window.__antcatJsErrors = []
      window.addEventListener('error', (event) => {
        // Failed `<img>`/`<script>` loads also fire `error`, but do not bubble to `window`.
        window.__antcatJsErrors.push(`${event.message} (${event.filename}:${event.lineno}:${event.colno})`)
      })
      window.addEventListener('unhandledrejection', (event) => {
        const reason = event.reason
        window.__antcatJsErrors.push(`Unhandled promise rejection: ${(reason && (reason.stack || reason.message)) || reason}`)
      })
    })()
  JS

  # Scripts that every page must have loaded and run: jQuery and the typeahead plugin (application.js,
  # header quick search), Turbo and Stimulus (hotwire_app.js, deferred) and `AntCat` helpers (global.js).
  PAGE_SCRIPTS_LOADED = <<~JS.squish
    document.readyState === 'complete' &&
      typeof window.jQuery === 'function' &&
      typeof window.jQuery.fn.typeahead === 'function' &&
      typeof window.Turbo === 'object' &&
      typeof window.Stimulus === 'object' &&
      typeof window.AntCat === 'object' &&
      typeof window.AntCat.notifySuccess === 'function'
  JS

  def install_js_error_collector
    page.driver.browser.page.command("Page.addScriptToEvaluateOnNewDocument", source: JS_ERROR_COLLECTOR)
  end

  def wait_for_page_scripts
    page.document.synchronize do
      raise Capybara::ElementNotFound, "page scripts did not finish loading" unless page.evaluate_script(PAGE_SCRIPTS_LOADED)
    end
  end

  def expect_no_js_errors
    errors = page.evaluate_script('window.__antcatJsErrors')
    raise "JavaScript error collector is not installed, call `install_js_error_collector` before `visit`" if errors.nil?

    expect(errors).to eq([]), "Uncaught JavaScript errors on #{current_url}:\n#{errors.join("\n")}"
  end
end

RSpec.configure do |config|
  config.include JavascriptErrorHelpers, type: :feature

  # Records which examples ran in headless Chrome; CI reads this to show that browser specs ran
  # (and were not skipped). See "Report browser specs" in `.github/workflows/main.yml`.
  js_example_ids = []
  config.after(:each, :js) { |example| js_example_ids << example.id }
  config.after(:suite) do
    Rails.root.join("tmp/js_example_ids.txt").write(js_example_ids.join("\n")) if ENV['CI']
  end
end
