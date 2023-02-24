# frozen_string_literal: true

# General steps, not specific to AntCat.
module FeatureHelpers
  module Steps
    def with_scope locator, &block
      within(*selector_for(locator), &block)
    end

    def javascript_driver?
      Capybara.current_driver == Capybara.javascript_driver
    end

    # Browser/navigation.
    def i_should_be_on page_name
      current_path = URI.parse(current_url).path
      expect(current_path).to eq path_to(page_name)
    end

    def i_reload_the_page
      visit current_path
    end

    # Click/press/follow.
    def i_click_on location
      css_selector = selector_for location
      find(css_selector).click
    end

    def i_follow_the_first link_text
      first(:link, link_text, exact: true).click
    end

    def i_follow link_text, within: nil
      if within
        with_scope within do
          click_link link_text
        end
      else
        click_link link_text
      end
    end

    # "I should see / should contain".
    def i_should_see content, within: nil
      if within
        with_scope within do
          expect(page).to have_content content
        end
      else
        expect(page).to have_content content
      end
    end

    def i_should_not_see content, within: nil
      if within
        with_scope within do
          expect(page).to have_no_content content
        end
      else
        expect(page).to have_no_content content
      end
    end

    def the_field_should_contain field_name, value
      field = find_field(field_name)
      expect(field.value).to eq value
    end

    # JavaScript alerts and prompts.
    def i_will_confirm_on_the_next_step
      evaluate_script "window.alert = function(msg) { return true; }"
      evaluate_script "window.confirm = function(msg) { return true; }"
      evaluate_script "window.prompt = function(msg) { return true; }"
    rescue Capybara::NotSupportedByDriverError
      nil
    end
  end
end
