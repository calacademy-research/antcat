# frozen_string_literal: true

require 'rails_helper'

describe "application/_flash_messages" do
  it "keeps links but drops attributes that make them send requests" do
    controller.flash[:notice] = %(<a href="/x" data-method="delete" data-remote="true" class="btn-default" title="t">x</a>)

    render partial: "application/flash_messages"

    link = Nokogiri::HTML5.fragment(rendered).at('a')
    expect(link['href']).to eq '/x'
    expect(link['class']).to eq 'btn-default'
    expect(link['data-method']).to be_nil
    expect(link['data-remote']).to be_nil
  end
end
