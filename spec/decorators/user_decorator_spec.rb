require 'spec_helper'

describe UserDecorator do
  let(:user) { create :user, name: "First Last", email: "email@example.com" }

  describe "#name_linking_to_email" do
    it "formats email and name" do
      expect(user.decorate.name_linking_to_email)
        .to eq '<a href="mailto:email@example.com">First Last</a>'
    end
  end
end
