# frozen_string_literal: true

require 'rails_helper'

feature "Export references to EndNote" do
  scenario "Exporting an `ArticleReference`" do
    there_is_an_article_reference

    i_go_to 'the page of the most recent reference'
    i_follow "EndNote"
    i_should_see "%0 Journal Article %A "
  end
end
