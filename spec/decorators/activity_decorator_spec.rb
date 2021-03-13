# frozen_string_literal: true

require 'rails_helper'

describe ActivityDecorator do
  include TestLinksHelpers

  subject(:decorated) { activity.decorate }

  describe ".link_taxon_if_exists" do
    context "when taxon exists" do
      let(:taxon) { create :subfamily }

      it "links the taxon" do
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

  describe ".link_protonym_if_exists" do
    context "when protonym exists" do
      let(:protonym) { create :protonym }

      it "links the protonym and its terminal taxa" do
        expect(described_class.link_protonym_if_exists(protonym.id)).
          to eq protonym_link(protonym) << " (no terminal taxon)"
      end
    end

    context "when protonym doesn't exist" do
      it "returns the id and more" do
        expect(described_class.link_protonym_if_exists(99999)).to eq "#99999 [deleted]"
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
      context 'when trackable is a `Name`' do
        let(:trackable) { create :genus_name, name: 'Lasius' }

        context 'when `names.name` was not changed' do
          let(:activity) do
            trackable.update!(non_conforming: true)
            trackable.create_activity Activity::UPDATE, user
          end

          specify do
            expect(decorated.did_something.squish).to eq <<~STR.squish
              edited the name record <a href="/names/#{trackable.id}">#{trackable.name_html}</a>
            STR
          end
        end

        context 'when `names.name` was changed' do
          let(:activity) do
            trackable.update!(name: 'Atta')
            trackable.create_activity Activity::UPDATE, user
          end

          it 'includes the old and new names' do
            expect(decorated.did_something.squish).to eq <<~STR.squish
              edited the name record <a href="/names/#{trackable.id}">#{trackable.name_html}</a>
              <div class='small-text bold-warning'> Name changed from Lasius to Atta </div>
            STR
          end
        end
      end

      context 'when trackable is a `Taxon`' do
        context 'when action is `Activity::FORCE_UPDATE_DATABASE_RECORD`' do
          let(:trackable) { create :family }
          let(:activity) { trackable.create_activity Activity::FORCE_UPDATE_DATABASE_RECORD, user }

          specify do
            expect(decorated.did_something.squish).to eq <<~HTML.squish
              <span class='bold-warning'>force-updated</span>
              the record
              #{taxon_link(trackable)}
              (<code>Taxon##{trackable.id}</code>)
            HTML
          end
        end
      end

      context 'when trackable is a `Reference`' do
        context 'when action is `Activity::UPDATE`' do
          let(:trackable) { create :any_reference }
          let(:activity) { trackable.create_activity Activity::UPDATE, user }

          specify do
            expect(decorated.did_something.squish).
              to eq %(edited the reference #{reference_link(trackable)})
          end
        end

        context 'when action is `Activity::START_REVIEWING`' do
          let(:trackable) { create :any_reference }
          let(:activity) { trackable.create_activity Activity::START_REVIEWING, user }

          specify do
            expect(decorated.did_something.squish).
              to eq %(started reviewing the reference #{reference_link(trackable)})
          end
        end

        context 'when action is `Activity::FINISH_REVIEWING`' do
          let(:trackable) { create :any_reference }
          let(:activity) { trackable.create_activity Activity::FINISH_REVIEWING, user }

          specify do
            expect(decorated.did_something.squish).
              to eq %(finished reviewing the reference #{reference_link(trackable)})
          end
        end

        context 'when action is `Activity::RESTART_REVIEWING`' do
          let(:trackable) { create :any_reference }
          let(:activity) { trackable.create_activity Activity::RESTART_REVIEWING, user }

          specify do
            expect(decorated.did_something.squish).
              to eq %(restarted reviewing the reference #{reference_link(trackable)})
          end
        end
      end

      context 'when trackable is a `Tooltip`' do
        let(:trackable) { create :tooltip, scope: 'taxa', key: 'authors' }
        let(:activity) { trackable.create_activity Activity::UPDATE, user }

        specify do
          expect(decorated.did_something.squish).
            to eq %(edited the tooltip <a href="/tooltips/#{trackable.id}">#{trackable.scope}.#{trackable.key}</a>)
        end
      end
    end

    context 'when there is no trackable' do
      context 'when action is `Activity::EXECUTE_SCRIPT`' do
        let(:activity) { Activity.execute_script_activity(user, "an edit summary") }

        specify do
          expect(decorated.did_something.squish).to eq "executed a script"
        end
      end

      context 'when action is `Activity::APPROVE_ALL_REFERENCES`' do
        let(:activity) { Activity.create_without_trackable Activity::APPROVE_ALL_REFERENCES, user, parameters: { count: 1 } }

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
        let(:activity) { build_stubbed :activity, trackable: nil, action: Activity::DESTROY }

        it "does not add '[deleted]' to the label" do
          expect(decorated.link_trackable_if_exists("label")).to eq "label"
        end
      end
    end
  end

  describe "#action_to_verb" do
    it "past participle-ifies defined actions" do
      decorated = build_stubbed(:activity, action: Activity::CREATE).decorate
      expect(decorated.action_to_verb).to eq "added"
    end

    it "uglifies missing actions" do
      decorated = build_stubbed(:activity, action: "bake_a_cake").decorate
      expect(decorated.action_to_verb).to eq "BAKE_A_CAKE"
    end
  end
end
