require "spec_helper"

describe FeedHelper do
  let(:activity) { create :activity }

  describe "#format_activity" do
    # TODO
  end

  describe "#link_activity_user" do
    describe "with a valid user" do
      it "links the user" do
        expect(helper.link_activity_user activity)
          .to include activity.user.name
      end
    end

    describe "without a valid user" do
      it "handles nil / 'system' activities" do
        system_activity = create :activity, user: nil
        expect(helper.link_activity_user system_activity)
          .to include "[system]"
      end
    end
  end

  describe "#link_trackable_if_exists" do
    describe "with a valid trackable" do
      it "links the trackable" do
        trackable_id = activity.trackable_id
        expect(helper.link_trackable_if_exists activity, "label")
          .to eq %Q[<a href="/journals/#{trackable_id}">label</a>]
      end
    end

    describe "without a valid trackable" do
      it "handles nil trackables" do
        activity_without_trackable = create :activity, trackable: nil
        expect(helper.link_trackable_if_exists activity_without_trackable, "label")
          .to eq "label"
      end
    end
  end

  describe "#activity_action_to_verb" do
    it "past participle-ifies defined actions" do
      expect(helper.activity_action_to_verb "create")
        .to eq "added"
    end

    it "uglifies missing actions" do
      expect(helper.activity_action_to_verb "bake_a_cake")
        .to eq "BAKE_A_CAKE"
    end
  end

  describe "#trackabe_type_to_human" do
    it "converts camelcase to spaced downcased" do
      expect(helper.trackabe_type_to_human "BookReference")
        .to eq "book reference"
    end
  end
end
