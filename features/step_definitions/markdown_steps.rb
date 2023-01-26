# frozen_string_literal: true

def markdown_textarea
  find ".preview-area textarea"
end

def i_am_on_a_page_with_a_textarea_with_markdown_preview_and_autocompletion
  i_go_to 'the open issues page'
  i_follow "New"
end

def i_fill_in_with_followed_by_the_user_id_of textarea, text, name
  user = User.find_by!(name: name)
  i_fill_in textarea.to_s, with: "#{text}#{user.id}"
end

# HACK: Because the below selects the wrong suggestion (which is hidden).
#   `first(".atwho-view-ul li.cur", visible: true).click`
def i_click_the_suggestion_containing text
  find(".atwho-view-ul li", text: text).click
end

def the_markdown_textarea_should_contain_a_markdown_link_to_archibalds_user_page
  archibald = User.find_by!(name: "Archibald")
  expect(markdown_textarea.value).to include "@user#{archibald.id}"
end

def the_markdown_textarea_should_contain_a_markdown_link_to key_with_year
  reference = ReferenceStepsHelpers.find_reference_by_key(key_with_year)
  expect(markdown_textarea.value).to include Taxt.ref(reference.id)
end

def i_fill_in_with_and_a_markdown_link_to field_name, value, key_with_year
  reference = ReferenceStepsHelpers.find_reference_by_key(key_with_year)
  i_fill_in field_name, with: "#{value} #{Taxt.ref(reference.id)}"
end

def the_markdown_textarea_should_contain_a_markdown_link_to_eciton
  eciton = Taxon.find_by!(name_cache: "Eciton")
  expect(markdown_textarea.value).to include Taxt.tax(eciton.id)
end

def i_clear_the_markdown_textarea
  i_fill_in "issue_description", with: "%rsomething_to_clear_the_suggestions"
  markdown_textarea.set ""
end

def there_should_be_a_textarea_with_markdown_and_autocompletion
  find "textarea[data-previewable]"
  find "textarea[data-has-mentionables]"
  find "textarea[data-has-linkables]"
end
