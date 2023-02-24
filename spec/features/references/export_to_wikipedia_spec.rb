# frozen_string_literal: true

require 'rails_helper'

feature "Export references to Wikipedia", as: :visitor do
  scenario "Exporting an `ArticleReference`" do
    reference = create :article_reference, :with_author_name

    visit reference_path(reference)
    i_follow "Wikipedia"
    i_should_see "{{cite journal"
  end
end
