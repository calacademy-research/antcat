# frozen_string_literal: true

require 'rails_helper'

feature "Compare revisions", skip_ci: true, as: :editor, versioning: true do
  def i_add_a_history_item content
    find(:testid, 'add-history-item-button').click
    fill_in "taxt", with: content
    click_button "Save"
  end

  def i_follow_the_second_cur
    all(:link, "cur", exact: true)[1].click
  end

  def left_side_of_the_diff
    all(".callout .diff")[0]
  end

  def right_side_of_the_diff
    all(".callout .diff")[1]
  end

  scenario "Comparing history item revisions" do
    protonym = create :protonym

    # Added item.
    visit protonym_path(protonym)
    i_add_a_history_item "initial content"
    history_item = HistoryItem.last

    visit history_item_path(history_item)
    i_follow "History"
    i_should_see "This item does not have any previous revisions"

    # Edited.
    history_item.update!(taxt: "second revision content")
    visit history_item_path(history_item)
    i_follow "History"
    i_should_see "Current version"
    i_should_see "second revision content"
    i_should_not_see "initial content"

    i_follow "prev"
    i_should_see "Difference between revisions"
    i_should_see "initial content"

    # Deleted.
    history_item.destroy!
    visit activities_path
    i_follow_the_first "History"
    i_should_see "Version before item was deleted"
    i_should_see "second revision content"

    i_follow "cur"
    i_should_see "Difference between revisions"
    i_should_see "initial content"
  end

  scenario "Comparing reference section revisions" do
    reference_section = create :reference_section

    visit reference_section_path(reference_section)
    i_follow "History"
    i_should_see "This item does not have any previous revisions"
  end

  scenario "Comparing revisions with intermediate revisions", :js do
    history_item = create :history_item, :taxt, taxt: "initial version"
    history_item.update!(taxt: "second version")
    history_item.update!(taxt: "last version")

    visit history_item_path(history_item)
    i_follow "History"
    sleep 1 # TODO: Remove.
    click_button "Compare selected revisions"
    expect(left_side_of_the_diff).to have_content "second version"
    expect(right_side_of_the_diff).to have_content "last version"
    i_should_not_see "initial version"

    i_follow_the_second_cur
    expect(left_side_of_the_diff).to have_content "initial version"
    expect(right_side_of_the_diff).to have_content "last version"
    i_should_not_see "second version"
  end
end
