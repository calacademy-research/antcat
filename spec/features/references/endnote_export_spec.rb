# frozen_string_literal: true

require 'rails_helper'

feature "Export references to EndNote", as: :visitor do
  scenario "Exporting an `ArticleReference`" do
    reference = create :article_reference, :with_author_name

    visit reference_path(reference)
    i_follow "EndNote"
    i_should_see "%0 Journal Article %A "
  end
end
