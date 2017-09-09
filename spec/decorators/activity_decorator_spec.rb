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
        expect(activity.decorate.link_user).to include "[system]"
      end
    end
  end

  describe "#did_something" do
    # TODO
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
    context "no `trackable_type`" do
      let(:activity) { create :activity, trackable: nil, action: "approved_all" }

      it "returns the action" do
        expect(activity.decorate.send :template_partial)
          .to eq "activities/templates/actions/approved_all"
      end
    end

    context "there's a partial matching `action`" do
      let(:activity) do
        create :activity, trackable: create_species, action: "elevate_subspecies_to_species"
      end

      it "returns the action" do
        expect(activity.decorate.send :template_partial)
          .to eq "activities/templates/actions/elevate_subspecies_to_species"
      end
    end

    context "there's a partial matching `trackable_type`" do
      it "returns that spaced and downcased" do
        expect(activity.decorate.send :template_partial)
          .to eq "activities/templates/journal"
      end
    end

    context "there's no partial matching `trackable_type`" do
      let(:activity) { create :activity, trackable: create(:citation) }

      it "returns the default template" do
        expect(activity.decorate.send :template_partial)
          .to eq "activities/templates/default"
      end
    end
  end
end
