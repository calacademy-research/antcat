# frozen_string_literal: true

require 'rails_helper'

describe "Markup in comments" do
  let!(:comment) { create :comment, body: %(<div class="callout-danger user-made-class" title="t">Official-looking notice</div>) }

  it "drops `class` attributes, so comments cannot look like the site's own notices" do
    get issue_path(comment.commentable)

    expect(response).to have_http_status :ok
    expect(response.body).to include "Official-looking notice"
    page = Nokogiri::HTML5(response.parsed_body.to_s)
    expect(page.css('div[title="t"]').map(&:text)).to eq ["Official-looking notice"]
    expect(page.css('.user-made-class')).to be_empty
  end

  it "drops the language label of fenced code blocks, which would otherwise become a `class` attribute" do
    code_comment = create :comment, body: "```{.callout-danger .user-code-class}\nOfficial-looking code\n```"
    get issue_path(code_comment.commentable)

    expect(response).to have_http_status :ok
    page = Nokogiri::HTML5(response.parsed_body.to_s)
    expect(page.css('pre code').map(&:text).join).to include "Official-looking code"
    expect(page.css('.user-code-class, .callout-danger pre, pre.callout-danger, code.callout-danger')).to be_empty
  end
end
