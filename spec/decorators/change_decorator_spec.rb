require 'spec_helper'

describe ChangeDecorator do
  let(:user) { build_stubbed :user, name: "First Last", email: "email@example.com" }

  describe "#format_adder_name" do
    let(:change) { build_stubbed :change, approver: user, change_type: "create" }

    it "formats the adder's name" do
      allow(change).to receive(:changed_by).and_return user

      results = change.decorate.format_adder_name
      expect(results).to match /First Last/
      expect(results).to match(/ added$/)
    end
  end

  describe "#format_approver_name" do
    let(:change) { build_stubbed :change, approver: user }

    it "formats the approver's name" do
      results = change.decorate.format_approver_name
      expect(results).to match /First Last/
      expect(results).to match /approved this change/
    end
  end

  describe "#format_time_ago" do
    let(:nil_decorator) { described_class.new nil }
    let(:time) { Time.now - 1.hour }

    it "formats time" do
      expect(nil_decorator.send(:format_time_ago, time))
        .to match %r{<span>about 1 hour ago</span>}
    end
  end
end
