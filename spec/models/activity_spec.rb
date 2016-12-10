require "spec_helper"

describe Activity, feed: true do
  describe ".create_for_trackable" do
    context "feed is globally enabled" do
      it "creates activities" do
        expect do
          Activity.create_for_trackable nil, nil
        end.to change { Activity.count }.by 1
      end
    end

    context "feed is globally disabled" do
      before { Feed.enabled = false }

      it "doesn't create activities" do
        Activity.create_for_trackable nil, nil
        expect(Activity.count).to eq 0
      end
    end
  end
end
