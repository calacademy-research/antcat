# frozen_string_literal: true

require 'rails_helper'

feature "Layout" do
  background do
    i_am_logged_in
  end

  scenario "Showing unescaped HTML characters in the title" do
    i_go_to "the Editor's Panel"
    expect(page.title).to eq "Editor's Panel - AntCat"
  end
end
