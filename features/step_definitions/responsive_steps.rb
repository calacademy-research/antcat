When /^I resize the browser window to (mobile|tablet|desktop)$/ do |device|
  size = case device.to_sym
         when :mobile then  [640, 480]
         when :tablet then  [960, 640]
         when :desktop then [1024, 768]
         end

  resize_window size
end

Then /^I should see the desktop site$/ do
  selenium_only do
    page.should have_css("#desktop-only", visible: true)
    page.should have_no_css("#mobile-only", visible: true)
  end
end

Then /^I should see the mobile site$/ do
  selenium_only do
    page.should have_css("#mobile-only", visible: true)
    page.should have_no_css("#desktop-only", visible: true)
  end
end

def resize_window size
  current_browser = Capybara.current_session.driver.browser
  return unless current_browser.respond_to? :manage
  current_browser.manage.window.resize_to *size
end

# Too much of a hassle to get this working in Webkit
def selenium_only
  if Capybara.javascript_driver == :selenium
    yield
  else
    $stderr.puts "not running Selenium = not testing responsiveness".yellow
  end
end
