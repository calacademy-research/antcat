# frozen_string_literal: true

require 'rails_helper'

feature "Add new nested reference button", as: :helper do
  scenario "Add new `NestedReference` using the button" do
    reference = create :article_reference, year: 2010, stated_year: 2011

    i_go_to 'the page of the most recent reference'
    i_follow "New Nested Reference"
    the_field_should_contain "reference_year", "2010"
    the_field_should_contain "reference_stated_year", "2011"
    the_field_should_contain "reference_pagination", "Pp. XX-XX in:"
    the_field_should_contain "reference_nesting_reference_id", reference.id.to_s
  end
end
