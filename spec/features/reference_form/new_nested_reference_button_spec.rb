# frozen_string_literal: true

require 'rails_helper'

feature "Add new nested reference button" do
  def nesting_reference_id_should_contain_a_valid_reference_id
    id = find("#reference_nesting_reference_id").value
    expect(Reference.exists?(id)).to eq true
  end

  scenario "Add new `NestedReference` using the button" do
    create :article_reference, year: 2010, stated_year: 2011
    i_log_in_as_a_helper_editor

    i_go_to 'the page of the most recent reference'
    i_follow "New Nested Reference"
    the_field_should_contain "reference_year", "2010"
    the_field_should_contain "reference_stated_year", "2011"
    the_field_should_contain "reference_pagination", "Pp. XX-XX in:"
    nesting_reference_id_should_contain_a_valid_reference_id
  end
end
