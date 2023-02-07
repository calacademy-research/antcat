# frozen_string_literal: true

require 'rails_helper'

feature "Export references to Wikipedia", as: :visitor do
  scenario "Exporting an `ArticleReference`" do
    create :article_reference, :with_author_name

    i_go_to 'the page of the most recent reference'
    i_follow "Wikipedia"
    i_should_see "{{cite journal"
  end
end
