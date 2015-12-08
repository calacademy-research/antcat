require 'spec_helper'

describe UserDecorator do
  let(:user) do
    FactoryGirl.create :user, name: "First Last", email: "email@example.com"
  end
  let(:decorated_user) { user.decorate }

  describe "#format_name_linking_to_email" do
    it "formats email and name" do
      expect(decorated_user.format_doer_name)
        .to eq '<a href="mailto:email@example.com">First Last</a>'
    end
  end

end
