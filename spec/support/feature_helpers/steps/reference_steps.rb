# frozen_string_literal: true

module FeatureHelpers
  module Steps
    def i_select_the_reference_tab tab_css_selector
      find(tab_css_selector, visible: false).click
    end
  end
end
