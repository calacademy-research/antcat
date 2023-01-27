# frozen_string_literal: true

require 'rails_helper'

feature "Editing references sections" do
  def there_is_a_subfamily_with_a_reference_section name, references_taxt
    taxon = create :subfamily, name_string: name
    create :reference_section, references_taxt: references_taxt, taxon: taxon
  end

  def the_reference_section_should_be_empty
    expect(page).not_to have_css '#reference-sections .reference_section'
  end

  def the_reference_section_should_be content
    element = first('#references-section').find('.taxt-presenter')
    expect(element.text).to match(/#{content}/)
  end

  background do
    i_log_in_as_a_catalog_editor_named "Archibald"
  end

  scenario "Adding a reference section (with edit summary)" do
    create :genus, name_string: "Atta"

    i_go_to 'the edit page for "Atta"'
    the_reference_section_should_be_empty

    i_click_on 'the add reference section button'
    fill_in "references_taxt", with: "New reference"
    fill_in "edit_summary", with: "added new stuff"
    click_button "Save"
    the_reference_section_should_be "New reference"

    i_go_to 'the activity feed'
    i_should_see "Archibald added the reference section #", within: 'the activity feed'
    i_should_see "belonging to Atta"
    i_should_see_the_edit_summary "added new stuff"
  end

  # @retry_ci
  scenario "Editing a reference section (with edit summary)", :js do
    there_is_a_subfamily_with_a_reference_section "Dolichoderinae", "Original reference"

    i_go_to 'the edit page for "Dolichoderinae"'
    the_reference_section_should_be "Original reference"

    i_click_on 'the edit reference section button'
    fill_in "references_taxt", with: "(none)"
    within "#references-section" do
      fill_in "edit_summary", with: "fix typo"
    end
    i_click_on 'the save reference section button'
    i_should_not_see "Original reference"
    the_reference_section_should_be "(none)"

    i_go_to 'the activity feed'
    i_should_see "Archibald edited the reference section #", within: 'the activity feed'
    i_should_see "belonging to Dolichoderinae"
    i_should_see_the_edit_summary "fix typo"
  end

  scenario "Editing a reference section (without JavaScript)" do
    create :reference_section, references_taxt: "California checklist"

    i_go_to 'the page of the most recent reference section'
    i_should_see "California checklist"

    i_follow "Edit"
    fill_in "references_taxt", with: "reference section content"
    click_button "Save"
    i_should_see "Successfully updated reference section."
    i_should_see "reference section content"
  end

  scenario "Editing a reference section, but cancelling", :js do
    there_is_a_subfamily_with_a_reference_section "Dolichoderinae", "Original reference"

    i_go_to 'the edit page for "Dolichoderinae"'
    i_click_on 'the edit reference section button'
    fill_in "references_taxt", with: "(none)"
    i_click_on 'the cancel reference section button'
    the_reference_section_should_be "Original reference"
  end

  scenario "Deleting a reference section (with feed)", :js do
    there_is_a_subfamily_with_a_reference_section "Dolichoderinae", "Original reference"

    i_go_to 'the edit page for "Dolichoderinae"'
    i_click_on 'the edit reference section button'
    i_will_confirm_on_the_next_step
    i_click_on 'the delete reference section button'
    the_reference_section_should_be_empty

    i_go_to 'the activity feed'
    i_should_see "Archibald deleted the reference section #", within: 'the activity feed'
    i_should_see "belonging to Dolichoderinae"
  end
end
