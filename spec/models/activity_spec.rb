require "spec_helper"

describe Activity, feed: true do
  it { is_expected.to be_versioned }
  it { is_expected.to validate_inclusion_of(:action).in_array Activity::ACTIONS }

  describe ".create_for_trackable" do
    context "when feed is globally enabled" do
      it "creates activities" do
        expect { described_class.create_for_trackable nil, nil }.
          to change { described_class.count }.by 1
      end
    end

    context "when feed is globally disabled" do
      before { Feed.enabled = false }

      it "doesn't create activities" do
        expect { described_class.create_for_trackable nil, nil }.
          to_not change { described_class.count }
      end
    end
  end
end
