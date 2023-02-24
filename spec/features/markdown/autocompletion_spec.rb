# frozen_string_literal: true

require 'rails_helper'

feature "Markdown autocompletion", as: :editor, js: true do
  def i_am_on_a_page_with_a_textarea_with_markdown_preview_and_autocompletion
    i_go_to 'the open issues page'
    i_follow "New"
  end

  def markdown_textarea
    find(".preview-area textarea")
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

  def the_markdown_textarea_should_contain_a_markdown_link_to reference
    expect(markdown_textarea.value).to include Taxt.ref(reference.id)
  end

  def i_clear_the_markdown_textarea
    fill_in "issue_description", with: "%rsomething_to_clear_the_suggestions"
    markdown_textarea.set ""
  end

  def the_markdown_textarea_should_contain_a_markdown_link_to_eciton
    eciton = Taxon.find_by!(name_cache: "Eciton")
    expect(markdown_textarea.value).to include Taxt.tax(eciton.id)
  end

  scenario "References markdown autocompletion", :skip_ci, :search do
    create :any_reference, author_string: "Giovanni, S.", title: "Giovanni's Favorite Ants", year: 1810
    joffre_1810 = create :any_reference, author_string: "Joffre, J.", title: "Joffre's Favorite Ants", year: 1810
    Sunspot.commit

    i_am_on_a_page_with_a_textarea_with_markdown_preview_and_autocompletion

    fill_in "issue_description", with: "{rfav"
    i_should_see "Giovanni's Favorite Ants"
    i_should_see "Joffre's Favorite Ants"

    i_clear_the_markdown_textarea
    i_should_not_see "Favorite Ants"

    fill_in "issue_description", with: "{rjof"
    i_click_the_suggestion_containing "Joffre's Favorite Ants"
    the_markdown_textarea_should_contain_a_markdown_link_to joffre_1810
  end

  scenario "Taxa markdown autocompletion", :skip_ci, :search do
    create :genus, name_string: "Eciton"
    create :genus, name_string: "Atta"
    Sunspot.commit
    i_am_on_a_page_with_a_textarea_with_markdown_preview_and_autocompletion

    fill_in "issue_description", with: "{tec"
    i_should_see "Eciton"

    i_click_the_suggestion_containing "Eciton"
    the_markdown_textarea_should_contain_a_markdown_link_to_eciton
  end

  scenario "User markdown autocompletion", :skip_ci do
    create :user, name: "Archibald"
    i_am_on_a_page_with_a_textarea_with_markdown_preview_and_autocompletion

    fill_in "issue_description", with: "@arch"
    i_click_the_suggestion_containing "Archibald"
    the_markdown_textarea_should_contain_a_markdown_link_to_archibalds_user_page
  end
end
