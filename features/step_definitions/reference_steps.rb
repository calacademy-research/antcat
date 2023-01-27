# frozen_string_literal: true

def i_select_the_reference_tab tab_css_selector
  find(tab_css_selector, visible: false).click
end

def nesting_reference_id_should_contain_a_valid_reference_id
  id = find("#reference_nesting_reference_id").value
  expect(Reference.exists?(id)).to eq true
end
