# frozen_string_literal: true

require 'rails_helper'

# TODO: Specs disabled for now since it became very flaky after migrating to cuprite.
xfeature "Markdown autocompletion", as: :editor, js: true do
  def i_am_on_a_page_with_a_textarea_with_markdown_preview_and_autocompletion
    visit new_issue_path
  end

  def markdown_textarea
    find(".preview-area textarea")
  end

  # HACK: Because the below selects the wrong suggestion (which is hidden).
  #   `first(".atwho-view-ul li.cur", visible: true).click`
  def i_click_the_suggestion_containing text
    find(".atwho-view-ul li", text: text).click
  end

  def i_clear_the_markdown_textarea
    fill_in "issue_description", with: "%rsomething_to_clear_the_suggestions"
    markdown_textarea.set ""
  end

  scenario "References markdown autocompletion", :search do
    create :any_reference, author_string: "Giovanni, S.", title: "Giovanni's Favorite Ants", year: 1810
    joffre_1810 = create :any_reference, author_string: "Joffre, J.", title: "Joffre's Favorite Ants", year: 1810
    Sunspot.commit

    i_am_on_a_page_with_a_textarea_with_markdown_preview_and_autocompletion

    wait_for_atwho_to_load
    fill_in "issue_description", with: "{rfav"
    i_should_see "Giovanni's Favorite Ants"
    i_should_see "Joffre's Favorite Ants"

    i_clear_the_markdown_textarea
    i_should_not_see "Favorite Ants"

    fill_in "issue_description", with: "{rjof"
    i_click_the_suggestion_containing "Joffre's Favorite Ants"
    expect(markdown_textarea.value).to include Taxt.ref(joffre_1810.id)
  end

  scenario "Taxa markdown autocompletion", :search do
    eciton = create :genus, name_string: "Eciton"
    create :genus, name_string: "Atta"
    Sunspot.commit
    i_am_on_a_page_with_a_textarea_with_markdown_preview_and_autocompletion

    wait_for_atwho_to_load
    fill_in "issue_description", with: "{tec"
    i_should_see "Eciton"

    i_click_the_suggestion_containing "Eciton"
    expect(markdown_textarea.value).to include Taxt.tax(eciton.id)
  end

  scenario "User markdown autocompletion" do
    user = create :user, name: "Archibald"
    i_am_on_a_page_with_a_textarea_with_markdown_preview_and_autocompletion

    wait_for_atwho_to_load
    fill_in "issue_description", with: "@arch"
    i_click_the_suggestion_containing "Archibald"
    expect(markdown_textarea.value).to include "@user#{user.id}"
  end
end
