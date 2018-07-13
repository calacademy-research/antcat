When(/^I resize the browser window to (mobile|tablet|desktop)$/) do |device|
  resize_window_to_device device
end

Then("I should see the desktop layout") do
  expect(page).to have_css "#desktop-only"
  expect(page).to have_no_css "#mobile-only"
end

Then("I should see the mobile layout") do
  expect(page).to have_css "#mobile-only"
  expect(page).to have_no_css "#desktop-only"
end

def resize_window_to_device device
  size = case device.to_sym
         when :mobile then  [640, 480]
         when :tablet then  [960, 640]
         when :desktop then [1024, 768]
         end
  resize_window *size
end

# From http://railsware.com/blog/2015/02/11/responsive-layout-tests-with-capybara-and-rspec/
def resize_window width, height
  case Capybara.current_driver
  when :selenium
    Capybara.current_session.driver.browser.manage.window.resize_to(width, height)
  when :webkit
    handle = Capybara.current_session.driver.current_window_handle
    Capybara.current_session.driver.resize_window_to(handle, width, height)
  else
    raise NotImplementedError,
      "resize_window is not supported for #{Capybara.current_driver} driver"
  end
end
