# frozen_string_literal: true

require 'rails_helper'

feature "Export references to Wikipedia", %(
  As an editor of Wikipedia
  I want generate wiki-formatted citation templates
  So that it's easier to add references to Wikipedia articles
) do
  scenario "Exporting an `ArticleReference`" do
    create :article_reference, :with_author_name

    i_go_to 'the page of the most recent reference'
    i_follow "Wikipedia"
    i_should_see "{{cite journal"
  end
end
