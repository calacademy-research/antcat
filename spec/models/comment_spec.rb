require "spec_helper"

describe Comment do
  it { should be_versioned }
  it { should validate_presence_of :body }
  it { should validate_presence_of :user }

  describe "#is_a_reply?" do
    context "it is a reply" do
      let(:reply) { build_stubbed :reply }
      it { expect(reply.is_a_reply?).to be true }
    end

    context "it is not a reply" do
      let(:comment) { build_stubbed :comment }
      it { expect(comment.is_a_reply?).to be false }
    end
  end
end
