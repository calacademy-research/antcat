require 'spec_helper'

describe UserDecorator do
  let(:user) do
    FactoryGirl.create :user, name: "First Last", email: "email@example.com"
  end

  describe "#format_name_linking_to_email" do
    it "formats email and name" do
      expect(user.decorate.format_doer_name)
        .to eq '<a href="mailto:email@example.com">First Last</a>'
    end

    it "formats correctly when the 'doer' is nil", pending: true do
      pending "TODO"
      string = user.decorate.format_doer_name
      expect(string).to eq('Someone')
    end
  end

end
