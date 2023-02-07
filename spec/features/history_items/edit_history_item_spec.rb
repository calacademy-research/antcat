# frozen_string_literal: true

require 'rails_helper'

feature "Editing a history item" do
  def there_is_a_subfamily_protonym_with_a_history_item name, taxt
    protonym = create :protonym, :family_group, name: create(:subfamily_name, name: name)
    create :history_item, :taxt, taxt: taxt, protonym: protonym
  end

  background do
    i_log_in_as_a_catalog_editor_named "Archibald"
  end

  scenario "Adding a history item (with edit summary)" do
    create :protonym, :genus_group, name: create(:genus_name, name: "Atta")

    i_go_to 'the protonym page for "Atta"'
    the_history_should_be_empty

    i_click_on 'the add history item button'
    fill_in "taxt", with: "Abc"
    fill_in "edit_summary", with: "added new stuff"
    click_button "Save"
    the_history_should_be "Abc"

    there_should_be_an_activity "Archibald added the history item #\\d+ belonging to Atta", edit_summary: "added new stuff"
  end

  scenario "Adding a history item with blank taxt" do
    create :protonym, :genus_group, name: create(:genus_name, name: "Atta")

    i_go_to 'the protonym page for "Atta"'
    the_history_should_be_empty

    i_click_on 'the add history item button'
    click_button "Save"
    i_should_see "Taxt can't be blank"
  end

  # @retry_ci
  scenario "Editing a history item (with edit summary)", :js do
    there_is_a_subfamily_protonym_with_a_history_item "Antcatinae", "Antcatinae as family"

    i_go_to 'the protonym page for "Antcatinae"'
    the_history_should_be "Antcatinae as family"

    wait_for_taxt_editors_to_load
    i_click_on 'the edit history item button'
    fill_in "taxt", with: "(none)"
    within "#history-items" do
      fill_in "edit_summary", with: "fix typo"
    end
    i_click_on 'the save history item button'
    i_reload_the_page
    i_should_not_see "Antcatinae as family"
    the_history_should_be "(none)"

    wait_for_taxt_editors_to_load
    i_click_on 'the edit history item button'
    the_history_item_field_should_be "(none)"

    there_should_be_an_activity "Archibald edited the history item #\\d+ belonging to Antcatinae", edit_summary: "fix typo"
  end

  scenario "Editing a history item (without JavaScript)" do
    there_is_a_subfamily_protonym_with_a_history_item "Antcatinae", "Antcatinae as family"

    i_go_to 'the page of the most recent history item'
    i_follow "Edit"
    i_should_see "Antcatinae as family"

    fill_in "taxt", with: "history item content"
    click_button "Save"
    i_should_see "Successfully updated history item #"
    i_should_see "history item content"
  end

  scenario "Editing a history item, but cancelling", :skip_ci, :js do
    there_is_a_subfamily_protonym_with_a_history_item "Antcatinae", "Antcatinae as family"

    i_go_to 'the protonym page for "Antcatinae"'
    wait_for_taxt_editors_to_load
    i_click_on 'the edit history item button'
    fill_in "taxt", with: "(none)"
    i_click_on 'the cancel history item button'
    the_history_should_be "Antcatinae as family"

    i_click_on 'the edit history item button'
    the_history_item_field_should_be "Antcatinae as family"
  end

  scenario "Deleting a history item (with feed)", :js do
    there_is_a_subfamily_protonym_with_a_history_item "Antcatinae", "Antcatinae as family"

    i_go_to 'the protonym page for "Antcatinae"'
    i_should_see "Antcatinae as family"

    wait_for_taxt_editors_to_load
    i_click_on 'the edit history item button'
    i_will_confirm_on_the_next_step
    i_click_on 'the delete history item button'
    i_should_be_on 'the protonym page for "Antcatinae"'

    i_reload_the_page
    the_history_should_be_empty

    there_should_be_an_activity "Archibald deleted the history item #\\d+ belonging to Antcatinae"
  end

  scenario "Seeing the markdown preview (and cancelling)", :js do
    giovanni_1809 = create :any_reference, author_string: "Giovanni, S.", year: 1809
    there_is_a_subfamily_protonym_with_a_history_item "Antcatinae", "As family, #{Taxt.ref(giovanni_1809.id)}"

    i_go_to 'the protonym page for "Antcatinae"'
    i_should_see "As family, Giovanni, 1809"
    the_history_item_field_should_not_be_visible

    wait_for_taxt_editors_to_load
    i_click_on 'the edit history item button'
    i_should_see "As family, Giovanni, 1809"
    the_history_item_field_should_be_visible

    fill_in "taxt", with: "Lasius history, #{Taxt.ref(giovanni_1809.id)}"
    click_button "Rerender preview"
    i_should_see "Lasius history, Giovanni, 1809"

    i_click_on 'the cancel history item button'
    i_should_see "As family, Giovanni, 1809"
    the_history_item_field_should_not_be_visible
  end
end
