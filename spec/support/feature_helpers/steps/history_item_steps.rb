# frozen_string_literal: true

module FeatureHelpers
  module Steps
    # Editing.
    def the_history_should_be content
      element = first('#history-items').find('.taxt-presenter')
      expect(element).to have_content(content)
    end

    def the_history_item_field_should_be content
      element = first('#history-items').find('textarea')
      expect(element).to have_content(content)
    end

    def the_history_item_field_should_not_be_visible
      expect(page).not_to have_css '#history-items textarea'
    end

    def the_history_item_field_should_be_visible
      expect(page).to have_css '#history-items textarea'
    end

    def the_history_should_be_empty
      expect(page).not_to have_css '#history-items .history-item'
    end
  end
end
