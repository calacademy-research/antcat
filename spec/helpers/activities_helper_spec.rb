require "spec_helper"

describe ActivitiesHelper do
  let(:activity) { create :activity }

  describe "#link_trackable_if_exists" do
    context "with a valid trackable" do
      it "links the trackable" do
        trackable_id = activity.trackable_id
        expect(helper.link_trackable_if_exists activity, "label")
          .to eq %Q[<a href="/journals/#{trackable_id}">label</a>]
      end

      it "defaults labels to the id" do
        trackable_id = activity.trackable_id
        expect(helper.link_trackable_if_exists activity)
          .to eq %Q[<a href="/journals/#{trackable_id}">##{trackable_id}</a>]
      end

      it "allows custom paths" do
        genus = create_genus
        activity = create :activity, trackable: genus
        trackable_id = activity.trackable_id

        results = helper.link_trackable_if_exists activity, "label", path: catalog_path(genus)
        expect(results).to eq %Q[<a href="/catalog/#{trackable_id}">label</a>]
      end
    end

    context "without a valid trackable" do
      let(:activity) { create :activity, trackable: nil }

      it "handles nil trackables" do
        expect(helper.link_trackable_if_exists activity, "label").to eq "label"
      end
    end
  end

  describe "#trackabe_type_to_human" do
    it "converts camelcase to spaced downcased" do
      expect(helper.trackabe_type_to_human "BookReference").to eq "book reference"
    end
  end
end
