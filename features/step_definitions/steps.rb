# frozen_string_literal: true

# General steps, not specific to AntCat.

# Browser/navigation.
def i_go_to page_name
  visit path_to(page_name)
end

def i_should_be_on page_name
  current_path = URI.parse(current_url).path
  expect(current_path).to eq path_to(page_name)
end

def the_page_title_be title
  expect(page.title).to eq title
end

def i_reload_the_page
  visit current_path
end

# Click/press/follow.
def i_click_on location
  css_selector = selector_for location
  find(css_selector).click
end

def i_click_css css_selector
  find(css_selector).click
end

def i_click_css_with_text css_selector, text
  find(css_selector, text: text).click
end

def i_press button_text
  click_button button_text
end

def i_follow_the_first link_text
  first(:link, link_text, exact: true).click
end

def i_follow_the_second link_text
  all(:link, link_text, exact: true)[1].click
end

def i_follow link_text, within: nil
  if within
    with_scope within do
      i_follow link_text
    end
  else
    click_link link_text
  end
end

# Interact with form elements.
def i_fill_in field_name, with:, within: nil
  if within
    with_scope within do
      fill_in field_name, with: with
    end
  else
    fill_in field_name, with: with
  end
end

def i_select value, from:
  select value, from: from
end

def i_check field_name
  check field_name
end

def i_uncheck field_name
  uncheck field_name
end

def i_should_see_checked field_name
  expect(page.find(field_name).checked?).to eq true
end

def i_should_see_unchecked field_name
  expect(page.find(field_name).checked?).to eq false
end

# "I should see / should contain".
def i_should_see content, within: nil
  if within
    with_scope within do
      expect(page).to have_content content, normalize_ws: true
    end
  else
    expect(page).to have_content content, normalize_ws: true
  end
end

def i_should_not_see content, within: nil
  if within
    with_scope within do
      i_should_not_see content
    end
  else
    expect(page).to have_no_content content
  end
end

def the_field_should_contain field_name, value
  field = find_field field_name
  expect(field.value).to match value
end

def the_field_within_should_contain field_name, parent_css_selector, value
  within parent_css_selector do
    field = find_field field_name
    expect(field.value).to match value
  end
end

# JavaScript alerts and prompts.
def i_should_see_an_alert message
  accept_alert(message) do
    # No-op.
  end
end

def i_will_confirm_on_the_next_step
  evaluate_script "window.alert = function(msg) { return true; }"
  evaluate_script "window.confirm = function(msg) { return true; }"
  evaluate_script "window.prompt = function(msg) { return true; }"
rescue Capybara::NotSupportedByDriverError
  nil
end
