# frozen_string_literal: true

require 'rails_helper'

describe "Markup in comments" do
  let!(:comment) { create :comment, body: %(<div class="callout-danger user-made-class" title="t">Official-looking notice</div>) }

  it "drops `class` attributes, so comments cannot look like the site's own notices" do
    get issue_path(comment.commentable)

    expect(response).to have_http_status :ok
    expect(response.body).to include "Official-looking notice"
    page = Nokogiri::HTML5(response.body)
    expect(page.css('div[title="t"]').map(&:text)).to eq ["Official-looking notice"]
    expect(page.css('.user-made-class')).to be_empty
  end
end
