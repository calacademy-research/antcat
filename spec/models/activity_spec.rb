# frozen_string_literal: true

require 'rails_helper'

describe Activity do
  it { is_expected.to be_versioned }

  describe 'validations' do
    it { is_expected.to validate_presence_of :action }
    it { is_expected.to validate_inclusion_of(:action).in_array(Activity::ACTIONS) }
  end

  it_behaves_like "a model that assigns `request_id` on create" do
    let(:instance) { build :activity }
  end

  describe ".create_for_trackable" do
    it "creates an activity" do
      expect { described_class.create_for_trackable(nil, :execute_script, user: nil) }.
        to change { described_class.count }.by 1
    end

    it "assigns attributes for the activity" do
      trackable = create :issue
      action = :update
      user = create :user
      edit_summary = 'pizza'
      parameters = { pizza: 'Hawaii' }

      activity =
        described_class.create_for_trackable(
          trackable,
          action,
          user: user,
          edit_summary: edit_summary,
          parameters: parameters
        )

      expect(activity.trackable).to eq trackable
      expect(activity.action).to eq action.to_s
      expect(activity.user).to eq user
      expect(activity.edit_summary).to eq edit_summary
      expect(activity.parameters).to eq parameters
    end
  end

  describe ".create_without_trackable" do
    it "creates an activity" do
      expect { described_class.create_without_trackable(:execute_script, nil) }.
        to change { described_class.count }.by 1
    end
  end

  describe '#pagination_page' do
    let!(:activity_1) { create :activity, automated_edit: true }
    let!(:activity_2) { create :activity }
    let!(:activity_3) { create :activity }
    let!(:activity_4) { create :activity, automated_edit: true }
    let!(:activity_5) { create :activity }

    before do
      allow(described_class).to receive(:per_page).and_return(2)
    end

    context 'when not using filters' do
      let(:activites) { described_class.all }

      specify do
        expect(activity_1.pagination_page(activites)).to eq 3
        expect(activity_2.pagination_page(activites)).to eq 2
        expect(activity_3.pagination_page(activites)).to eq 2
        expect(activity_4.pagination_page(activites)).to eq 1
        expect(activity_5.pagination_page(activites)).to eq 1
      end
    end

    context 'when using filters' do
      let(:activites) { described_class.non_automated_edits }

      specify do
        expect(activity_2.pagination_page(activites)).to eq 2
        expect(activity_3.pagination_page(activites)).to eq 1 # Different page when not using filters.
        expect(activity_5.pagination_page(activites)).to eq 1
      end
    end
  end
end
