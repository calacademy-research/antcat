require "spec_helper"

describe ActivityDecorator do
  let(:activity) { create :activity }

  describe "#link_user" do
    context "with a valid user" do
      it "links the user" do
        expect(activity.decorate.link_user).to include activity.user.name
      end
    end

    context "without a valid user" do
      let(:activity) { create :activity, user: nil }

      it "handles nil / 'system' activities" do
        expect(activity.decorate.link_user).to eq ""
      end
    end
  end

  describe "#did_something" do
    # TODO
  end

  describe "#link_trackable_if_exists" do
    context "with a valid trackable" do
      it "links the trackable" do
        trackable_id = activity.trackable_id
        expect(activity.decorate.link_trackable_if_exists("label")).
          to eq %Q(<a href="/journals/#{trackable_id}">label</a>)
      end

      it "defaults labels to the id" do
        trackable_id = activity.trackable_id
        expect(activity.decorate.link_trackable_if_exists).
          to eq %Q(<a href="/journals/#{trackable_id}">##{trackable_id}</a>)
      end

      it "allows custom paths" do
        genus = create_genus
        activity = create :activity, trackable: genus
        trackable_id = activity.trackable_id
        path = "/catalog/#{trackable_id}"

        results = activity.decorate.link_trackable_if_exists "label", path: path
        expect(results).to eq %Q(<a href="/catalog/#{trackable_id}">label</a>)
      end
    end

    context "without a valid trackable" do
      let(:activity) { create :activity, trackable: nil }

      it "handles nil trackables" do
        expect(activity.decorate.link_trackable_if_exists("label")).to eq "label"
      end
    end
  end

  describe "#trackabe_type_to_human" do
    let(:activity) { create :activity, trackable_type: "BookReference" }

    it "converts camelcase to spaced downcased" do
      expect(activity.decorate.trackabe_type_to_human).to eq "book reference"
    end
  end

  describe "#action_to_verb" do
    it "past participle-ifies defined actions" do
      decorated = build(:activity, action: "create").decorate
      expect(decorated.action_to_verb).to eq "added"
    end

    it "uglifies missing actions" do
      decorated = build(:activity, action: "bake_a_cake").decorate
      expect(decorated.action_to_verb).to eq "BAKE_A_CAKE"
    end
  end

  describe "#template_partial" do
    context "when  there's no `trackable_type`" do
      let(:activity) { create :activity, trackable: nil, action: "approve_all_changes" }

      it "returns the action" do
        expect(activity.decorate.send(:template_partial)).
          to eq "activities/templates/actions/approve_all_changes"
      end
    end

    context "when there's a partial matching `action`" do
      let(:activity) do
        create :activity, trackable: create_species, action: "elevate_subspecies_to_species"
      end

      it "returns the action" do
        expect(activity.decorate.send(:template_partial)).
          to eq "activities/templates/actions/elevate_subspecies_to_species"
      end
    end

    context "when there's a partial matching `trackable_type`" do
      it "returns that spaced and downcased" do
        expect(activity.decorate.send(:template_partial)).
          to eq "activities/templates/journal"
      end
    end

    context "when there's no partial matching `trackable_type`" do
      let(:activity) { create :activity, trackable: create(:citation) }

      it "returns the default template" do
        expect(activity.decorate.send(:template_partial)).
          to eq "activities/templates/default"
      end
    end
  end
end
