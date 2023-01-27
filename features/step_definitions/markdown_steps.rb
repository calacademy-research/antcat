# frozen_string_literal: true

def markdown_textarea
  find ".preview-area textarea"
end

def i_am_on_a_page_with_a_textarea_with_markdown_preview_and_autocompletion
  i_go_to 'the open issues page'
  i_follow "New"
end

def i_fill_in_with_and_a_markdown_link_to field_name, value, key_with_year
  reference = ReferenceStepsHelpers.find_reference_by_key(key_with_year)
  fill_in field_name, with: "#{value} #{Taxt.ref(reference.id)}"
end
