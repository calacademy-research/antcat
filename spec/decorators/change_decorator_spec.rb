require 'spec_helper'

describe ChangeDecorator do
  let(:user) do
    FactoryGirl.create :user, name: "First Last", email: "email@example.com"
  end

  describe "#format_adder_name" do
    it "formats the adder's name" do
      change = FactoryGirl.create :change, approver: user, change_type: "create"
      allow(change).to receive(:changed_by).and_return user

      string = change.decorate.format_adder_name
      expect(string).to match(/First Last/)
      expect(string).to match(/ added$/)
    end
  end

  describe "#format_approver_name" do
    it "formats the approver's name" do
      change = FactoryGirl.create :change, approver: user
      string = change.decorate.format_approver_name
      expect(string).to match(/First Last/)
      expect(string).to match(/approved this change/)
    end
  end

end
