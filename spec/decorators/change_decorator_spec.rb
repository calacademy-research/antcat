require 'spec_helper'

describe ChangeDecorator do
  let(:user) { build_stubbed :user, name: "First Last", email: "email@example.com" }

  describe "#format_adder_name" do
    let(:change) { build_stubbed :change, approver: user, change_type: "create" }

    specify do
      allow(change).to receive(:changed_by).and_return user
      expect(change.decorate.format_adder_name).to match /First Last.*? added/
    end
  end

  describe "#format_approver_name" do
    let(:change) { build_stubbed :change, approver: user }

    specify do
      expect(change.decorate.format_approver_name).to match /First Last.*? approved this change/
    end
  end
end
