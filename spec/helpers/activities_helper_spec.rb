require "spec_helper"

describe ActivitiesHelper do
  let(:activity) { create :activity }

  describe "#format_activity" do
    # TODO
  end

  describe "#link_activity_user" do
    context "with a valid user" do
      it "links the user" do
        expect(helper.link_activity_user activity).to include activity.user.name
      end
    end

    context "without a valid user" do
      it "handles nil / 'system' activities" do
        system_activity = create :activity, user: nil
        expect(helper.link_activity_user system_activity).to include "[system]"
      end
    end
  end

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

        actual = helper.link_trackable_if_exists activity, "label", path: catalog_path(genus)
        expect(actual).to eq %Q[<a href="/catalog/#{trackable_id}">label</a>]
      end
    end

    context "without a valid trackable" do
      let(:activity) { create :activity, trackable: nil }

      it "handles nil trackables" do
        expect(helper.link_trackable_if_exists activity, "label").to eq "label"
      end
    end
  end

  describe "#activity_action_to_verb" do
    it "past participle-ifies defined actions" do
      expect(helper.activity_action_to_verb "create").to eq "added"
    end

    it "uglifies missing actions" do
      expect(helper.activity_action_to_verb "bake_a_cake").to eq "BAKE_A_CAKE"
    end
  end

  describe "#trackabe_type_to_human" do
    it "converts camelcase to spaced downcased" do
      expect(helper.trackabe_type_to_human "BookReference").to eq "book reference"
    end
  end

  describe "#partial_for_activity" do
    context "no `trackable_type`" do
      let(:activity) { create :activity, trackable: nil, action: "approved_all" }

      it "returns the action" do
        expect(helper.send :partial_for_activity, activity)
          .to eq "feed/activities/actions/approved_all"
      end
    end

    context "there's a partial matching `action`" do
      let(:activity) do
        create :activity, trackable: create_species, action: "elevate_subspecies_to_species"
      end

      it "returns the action" do
        expect(helper.send :partial_for_activity, activity)
          .to eq "feed/activities/actions/elevate_subspecies_to_species"
      end
    end

    context "there's a partial matching `trackable_type`" do
      it "returns that spaced and downcased" do
        expect(helper.send :partial_for_activity, activity)
          .to eq "feed/activities/journal"
      end
    end

    context "there's no partial matching `trackable_type`" do
      let(:activity) { create :activity, trackable: create(:citation) }

      it "returns the default template" do
        expect(helper.send :partial_for_activity, activity)
          .to eq "feed/activities/default"
      end
    end
  end
end
