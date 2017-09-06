require "spec_helper"

describe Activity, feed: true do
  it { is_expected.to be_versioned }

  describe ".create_for_trackable" do
    context "feed is globally enabled" do
      it "creates activities" do
        expect { described_class.create_for_trackable nil, nil }
          .to change { described_class.count }.by 1
      end
    end

    context "feed is globally disabled" do
      before { Feed.enabled = false }

      it "doesn't create activities" do
        expect { described_class.create_for_trackable nil, nil }
          .to_not change { described_class.count }
      end
    end
  end
end
