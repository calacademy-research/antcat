require "spec_helper"

Activity = Feed::Activity

describe Feed::Activity, feed: true do
  describe ".create_activity_for_trackable" do
    context "globally enabled" do
      it "creates activities" do
        expect do
          Activity.create_activity_for_trackable nil, nil
        end.to change{ Activity.count }.by 1
      end
    end

    context "globally disabled" do
      it "doesn't create activities" do
        Activity.enabled = false
        Activity.create_activity_for_trackable nil, nil
        expect(Activity.count).to eq 0
      end
    end
  end

  describe "globally enabling and disabling tracking" do
    it "is enabled by default" do
      expect(Activity.enabled?).to be true
    end

    it "can be disabled and enabled" do
      Activity.enabled = false
      expect(Activity.enabled?).to be false

      Activity.enabled = true
      expect(Activity.enabled?).to be true
    end
  end

end
