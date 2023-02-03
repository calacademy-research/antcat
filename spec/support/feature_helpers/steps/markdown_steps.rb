# frozen_string_literal: true

module FeatureHelpers
  module Steps
    def i_am_on_a_page_with_a_textarea_with_markdown_preview_and_autocompletion
      i_go_to 'the open issues page'
      i_follow "New"
    end
  end
end
