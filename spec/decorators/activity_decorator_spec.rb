require 'rails_helper'

describe ActivityDecorator do
  describe "#link_user" do
    context "with a valid user" do
      let(:activity) { build_stubbed :activity, user: build_stubbed(:user) }

      it "links the user" do
        expect(activity.decorate.link_user).to include activity.user.name
      end
    end

    context "without a valid user" do
      let(:activity) { build_stubbed :activity, user: nil }

      it "handles nil / 'system' activities" do
        expect(activity.decorate.link_user).to eq ""
      end
    end
  end

  describe "#did_something" do
    include TestLinksHelpers

    let(:user) { build_stubbed :user }

    context 'when there is a trackable' do
      context 'when trackable is a `Reference`' do
        context 'when action is `update`' do
          let!(:trackable) { create :article_reference }

          specify do
            activity = trackable.create_activity :update, user
            expect(activity.decorate.did_something.squish).
              to eq %(edited the reference <a href="/references/#{trackable.id}">#{trackable.keey}</a>)
          end
        end

        context 'when action is `start_reviewing`' do
          let!(:trackable) { create :article_reference, review_state: 'none' }

          specify do
            activity = trackable.create_activity :start_reviewing, user
            expect(activity.decorate.did_something.squish).
              to eq %(started reviewing the reference <a href="/references/#{trackable.id}">#{trackable.keey}</a>)
          end
        end

        context 'when action is `finish_reviewing`' do
          let!(:trackable) { create :article_reference, review_state: 'reviewing' }

          specify do
            activity = trackable.create_activity :finish_reviewing, user
            expect(activity.decorate.did_something.squish).
              to eq %(finished reviewing the reference <a href="/references/#{trackable.id}">#{trackable.keey}</a>)
          end
        end

        context 'when action is `restart_reviewing`' do
          let!(:trackable) { create :article_reference, review_state: 'reviewed' }

          specify do
            activity = trackable.create_activity :restart_reviewing, user
            expect(activity.decorate.did_something.squish).
              to eq %(restarted reviewing the reference <a href="/references/#{trackable.id}">#{trackable.keey}</a>)
          end
        end
      end

      context 'when trackable is a `Tooltip`' do
        let!(:trackable) { create :tooltip, scope: 'taxa', key: 'authors' }

        specify do
          activity = trackable.create_activity :update, user
          expect(activity.decorate.did_something.squish).
            to eq %(edited the tooltip <a href="/tooltips/#{trackable.id}">#{trackable.scope}.#{trackable.key}</a>)
        end
      end
    end

    context 'when there is no trackable' do
      context 'when action is `execute_script`' do
        specify do
          activity = Activity.execute_script_activity(user, "an edit summary")
          expect(activity.decorate.did_something.squish).to eq "executed a script"
        end
      end

      context 'when action is `approve_all_changes`' do
        specify do
          activity = Activity.create_without_trackable :approve_all_changes, user, parameters: { count: 1 }
          expect(activity.decorate.did_something.squish).
            to eq "approved all unreviewed catalog changes (1 in total)."
        end
      end

      context 'when action is `approve_all_changes`' do
        specify do
          activity = Activity.create_without_trackable :approve_all_references, user, parameters: { count: 1 }
          expect(activity.decorate.did_something.squish).
            to eq "approved all unreviewed references (1 in total)."
        end
      end
    end
  end

  describe "#link_trackable_if_exists" do
    let(:activity) { build_stubbed :activity }

    context "with a valid trackable" do
      it "links the trackable" do
        trackable_id = activity.trackable_id
        expect(activity.decorate.link_trackable_if_exists("label")).
          to eq %(<a href="/journals/#{trackable_id}">label</a>)
      end

      it "defaults labels to the id" do
        trackable_id = activity.trackable_id
        expect(activity.decorate.link_trackable_if_exists).
          to eq %(<a href="/journals/#{trackable_id}">##{trackable_id}</a>)
      end

      it "allows custom paths" do
        taxon = build_stubbed :family
        activity = build_stubbed :activity, trackable: taxon
        trackable_id = activity.trackable_id
        path = "/catalog/#{trackable_id}"

        results = activity.decorate.link_trackable_if_exists "label", path: path
        expect(results).to eq %(<a href="/catalog/#{trackable_id}">label</a>)
      end
    end

    context "without a valid trackable" do
      context "when action is not 'destroy'" do
        let(:activity) { build_stubbed :activity, trackable: nil }

        it "add '[deleted]' to the label" do
          expect(activity.decorate.link_trackable_if_exists("label")).to eq "label [deleted]"
        end
      end

      context "when action is 'destroy'" do
        let(:activity) { build_stubbed :activity, trackable: nil, action: :destroy }

        it "does not add '[deleted]' to the label" do
          expect(activity.decorate.link_trackable_if_exists("label")).to eq "label"
        end
      end
    end
  end

  describe "#trackabe_type_to_human" do
    let(:activity) { build_stubbed :activity, trackable_type: "BookReference" }

    it "converts camelcase to spaced downcased" do
      expect(activity.decorate.trackabe_type_to_human).to eq "book reference"
    end
  end

  describe "#action_to_verb" do
    it "past participle-ifies defined actions" do
      decorated = build_stubbed(:activity, action: "create").decorate
      expect(decorated.action_to_verb).to eq "added"
    end

    it "uglifies missing actions" do
      decorated = build_stubbed(:activity, action: "bake_a_cake").decorate
      expect(decorated.action_to_verb).to eq "BAKE_A_CAKE"
    end
  end

  describe "#template_partial" do
    context "when  there's no `trackable_type`" do
      let(:activity) { build_stubbed :activity, trackable: nil, action: "approve_all_changes" }

      it "returns the action" do
        expect(activity.decorate.send(:template_partial)).
          to eq "activities/templates/actions/approve_all_changes"
      end
    end

    context "when there's a partial matching `action`" do
      let(:activity) do
        build_stubbed :activity, trackable: build_stubbed(:species), action: "elevate_subspecies_to_species"
      end

      it "returns the action" do
        expect(activity.decorate.send(:template_partial)).
          to eq "activities/templates/actions/elevate_subspecies_to_species"
      end
    end

    context "when there's a partial matching `trackable_type`" do
      let(:activity) { build_stubbed :activity }

      it "returns that spaced and downcased" do
        expect(activity.decorate.send(:template_partial)).
          to eq "activities/templates/journal"
      end
    end

    context "when there's no partial matching `trackable_type`" do
      let(:activity) { build_stubbed :activity, trackable: build_stubbed(:citation) }

      it "returns the default template" do
        expect(activity.decorate.send(:template_partial)).
          to eq "activities/templates/default"
      end
    end
  end
end
