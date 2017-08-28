require "spec_helper"

describe Comment do
  it { is_expected.to be_versioned }
  it { is_expected.to validate_presence_of :body }
  it { is_expected.to validate_presence_of :user }

  describe "#is_a_reply?" do
    context "it is a reply" do
      let(:reply) { build_stubbed :comment, :reply }

      it { expect(reply.is_a_reply?).to be true }
    end

    context "it is not a reply" do
      let(:comment) { build_stubbed :comment }

      it { expect(comment.is_a_reply?).to be false }
    end
  end
end
