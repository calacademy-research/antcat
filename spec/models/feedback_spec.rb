require 'spec_helper'

describe Feedback do

  it { should validate_presence_of(:comment) }

  describe "scopes" do
    describe "#recently_created" do
      before do
        FactoryGirl.create :feedback
        FactoryGirl.create :feedback, created_at: (Time.now - 8.minutes)
        FactoryGirl.create :feedback, created_at: (Time.now - 3.days)
      end

      it "defaults to 5 minutes" do
        expect(Feedback.recently_created.count).to eq 1
      end

      it "accepts any value" do
        expect(Feedback.recently_created(10.minutes.ago).count).to eq 2
        expect(Feedback.recently_created(7.days.ago).count).to eq 3
      end
    end
  end

  describe "#from_the_same_ip" do
    before do
      FactoryGirl.create :feedback
      FactoryGirl.create :feedback, ip: "255.255.255.255"
    end

    it "finds feedbacks from" do
      feedback = FactoryGirl.create :feedback
      expect(feedback.from_the_same_ip.count).to eq 2
    end
  end

end
