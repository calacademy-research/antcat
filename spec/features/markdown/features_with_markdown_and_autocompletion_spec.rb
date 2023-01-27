# frozen_string_literal: true

require 'rails_helper'

feature "Features with markdown and autocompletion", as: :editor do
  def there_should_be_a_textarea_with_markdown_and_autocompletion
    find "textarea[data-previewable]"
    find "textarea[data-has-mentionables]"
    find "textarea[data-has-linkables]"
  end

  scenario "Site notices" do
    i_go_to 'the site notices page'
    i_follow "New"
    there_should_be_a_textarea_with_markdown_and_autocompletion
  end

  scenario "Issues" do
    i_go_to 'the new issue page'
    there_should_be_a_textarea_with_markdown_and_autocompletion
  end

  scenario "Comments" do
    create :feedback, user: nil
    i_go_to 'the most recent feedback item'

    there_should_be_a_textarea_with_markdown_and_autocompletion
  end
end
