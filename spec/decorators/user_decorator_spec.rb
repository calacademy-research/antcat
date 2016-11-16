require 'spec_helper'

describe UserDecorator do
  let(:user) { build_stubbed :user, name: "First Last", email: "email@example.com" }

  describe "#name_linking_to_email" do
    it "formats email and name" do
      expect(user.decorate.name_linking_to_email)
        .to eq '<a href="mailto:email@example.com">First Last</a>'
    end
  end

  describe "#user_page_link" do
    it "link the name to the user page" do
      expect(user.decorate.user_page_link)
        .to eq %{<a href="/users/#{user.id}">First Last</a>}
    end
  end
end
