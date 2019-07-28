require "spec_helper"

describe Comment do
  it { is_expected.to be_versioned }
  it { is_expected.to validate_presence_of :body }
  it { is_expected.to validate_presence_of :user }

  describe "#a_reply?" do
    context "when it is a reply" do
      let(:reply) { build_stubbed :comment, :reply }

      specify { expect(reply.a_reply?).to eq true }
    end

    context "when it is not a reply" do
      let(:comment) { build_stubbed :comment }

      specify { expect(comment.a_reply?).to eq false }
    end
  end
end
