# frozen_string_literal: true

require 'rails_helper'

describe ActivityDecorator do
  include TestLinksHelpers

  let(:decorated) { activity.decorate }

  describe ".link_taxon_if_exists" do
    context "when taxon exists" do
      let(:taxon) { create :subfamily }

      it "returns a link" do
        expect(described_class.link_taxon_if_exists(taxon.id)).to eq taxon_link(taxon)
      end
    end

    context "when taxon doesn't exist" do
      it "returns the id and more" do
        expect(described_class.link_taxon_if_exists(99999)).to eq "#99999 [deleted]"
      end

      it "allows custom deleted_label" do
        expect(described_class.link_taxon_if_exists(99999, deleted_label: "deleted")).to eq "deleted"
      end
    end
  end

  describe "#link_user" do
    context "with a valid user" do
      let(:activity) { build_stubbed :activity, user: build_stubbed(:user) }

      it "links the user" do
        expect(decorated.link_user).to include activity.user.name
      end
    end

    context "without a valid user" do
      let(:activity) { build_stubbed :activity, user: nil }

      it "handles nil / 'system' activities" do
        expect(decorated.link_user).to eq nil
      end
    end
  end

  describe "#did_something" do
    let(:user) { build_stubbed :user }

    context 'when there is a trackable' do
      context 'when trackable is a `Reference`' do
        context 'when action is `update`' do
          let(:trackable) { create :any_reference }
          let(:activity) { trackable.create_activity :update, user }

          specify do
            expect(decorated.did_something.squish).
              to eq %(edited the reference <a href="/references/#{trackable.id}">#{trackable.keey}</a>)
          end
        end

        context 'when action is `start_reviewing`' do
          let(:trackable) { create :any_reference, review_state: 'none' }
          let(:activity) { trackable.create_activity :start_reviewing, user }

          specify do
            expect(decorated.did_something.squish).
              to eq %(started reviewing the reference <a href="/references/#{trackable.id}">#{trackable.keey}</a>)
          end
        end

        context 'when action is `finish_reviewing`' do
          let(:trackable) { create :any_reference, review_state: 'reviewing' }
          let(:activity) { trackable.create_activity :finish_reviewing, user }

          specify do
            expect(decorated.did_something.squish).
              to eq %(finished reviewing the reference <a href="/references/#{trackable.id}">#{trackable.keey}</a>)
          end
        end

        context 'when action is `restart_reviewing`' do
          let(:trackable) { create :any_reference, review_state: 'reviewed' }
          let(:activity) { trackable.create_activity :restart_reviewing, user }

          specify do
            expect(decorated.did_something.squish).
              to eq %(restarted reviewing the reference <a href="/references/#{trackable.id}">#{trackable.keey}</a>)
          end
        end
      end

      context 'when trackable is a `Tooltip`' do
        let(:trackable) { create :tooltip, scope: 'taxa', key: 'authors' }
        let(:activity) { trackable.create_activity :update, user }

        specify do
          expect(decorated.did_something.squish).
            to eq %(edited the tooltip <a href="/tooltips/#{trackable.id}">#{trackable.scope}.#{trackable.key}</a>)
        end
      end
    end

    context 'when there is no trackable' do
      context 'when action is `execute_script`' do
        let(:activity) { Activity.execute_script_activity(user, "an edit summary") }

        specify do
          expect(decorated.did_something.squish).to eq "executed a script"
        end
      end

      context 'when action is `approve_all_changes`' do
        let(:activity) { Activity.create_without_trackable :approve_all_changes, user, parameters: { count: 1 } }

        specify do
          expect(decorated.did_something.squish).
            to eq "approved all unreviewed catalog changes (1 in total)."
        end
      end

      context 'when action is `approve_all_references`' do
        let(:activity) { Activity.create_without_trackable :approve_all_references, user, parameters: { count: 1 } }

        specify do
          expect(decorated.did_something.squish).
            to eq "approved all unreviewed references (1 in total)."
        end
      end
    end
  end

  describe "#link_trackable_if_exists" do
    let(:activity) { build_stubbed :activity }

    context "with a valid trackable" do
      it "links the trackable" do
        expect(decorated.link_trackable_if_exists("label")).
          to eq %(<a href="/journals/#{activity.trackable_id}">label</a>)
      end

      it "defaults labels to the id" do
        expect(decorated.link_trackable_if_exists).
          to eq %(<a href="/journals/#{activity.trackable_id}">##{activity.trackable_id}</a>)
      end

      it "allows custom paths" do
        activity = build_stubbed :activity, trackable: build_stubbed(:any_taxon)

        results = decorated.link_trackable_if_exists "label", path: "/catalog/#{activity.trackable_id}"
        expect(results).to eq %(<a href="/catalog/#{activity.trackable_id}">label</a>)
      end
    end

    context "without a valid trackable" do
      context "when action is not 'destroy'" do
        let(:activity) { build_stubbed :activity, trackable: nil }

        it "adds '[deleted]' to the label" do
          expect(decorated.link_trackable_if_exists("label")).to eq "label [deleted]"
        end
      end

      context "when action is 'destroy'" do
        let(:activity) { build_stubbed :activity, trackable: nil, action: :destroy }

        it "does not add '[deleted]' to the label" do
          expect(decorated.link_trackable_if_exists("label")).to eq "label"
        end
      end
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
end
