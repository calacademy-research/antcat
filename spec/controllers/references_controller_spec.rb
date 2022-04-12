# frozen_string_literal: true

require 'rails_helper'

describe ReferencesController do
  describe "forbidden actions" do
    context "when not signed in", as: :visitor do
      specify { expect(get(:new)).to redirect_to_signin_form }
      specify { expect(get(:edit, params: { id: 1 })).to redirect_to_signin_form }
      specify { expect(post(:create)).to redirect_to_signin_form }
      specify { expect(put(:update, params: { id: 1 })).to redirect_to_signin_form }
    end

    context "when signed in as a helper editor", as: :helper do
      specify { expect(delete(:destroy, params: { id: 1 })).to have_http_status :forbidden }
    end
  end

  describe "GET index", as: :visitor do
    specify { expect(get(:index)).to render_template :index }
  end

  describe "POST create", as: :helper do
    let!(:reference_params) do
      {
        title: 'New Ants',
        year: 1999,
        year_suffix: 'b',
        stated_year: '2000',
        author_names_string: "Batiatus, B.; Glaber, G.",
        pagination: '5',
        journal_name: 'Zootaxa',
        series_volume_issue: '6',
        date: "19991220",
        doi: "10.10.1038/nphys117",
        bolton_key: "Smith 1858b",
        public_notes: "Public notes",
        editor_notes: "Editor notes",
        taxonomic_notes: "Taxonomic notes"
      }
    end
    let!(:params) do
      {
        reference_type: 'ArticleReference',
        reference: reference_params
      }
    end

    it 'creates a reference' do
      expect { post(:create, params: params) }.to change { Reference.count }.by(1)

      reference = Reference.last
      expect(reference.title).to eq reference_params[:title]
      expect(reference.year).to eq reference_params[:year]
      expect(reference.year_suffix).to eq reference_params[:year_suffix]
      expect(reference.stated_year).to eq reference_params[:stated_year]

      expect(reference.author_names_string).to eq reference_params[:author_names_string]

      expect(reference.journal.name).to eq reference_params[:journal_name]
      expect(reference.series_volume_issue).to eq reference_params[:series_volume_issue]

      expect(reference.date).to eq reference_params[:date]
      expect(reference.doi).to eq reference_params[:doi]
      expect(reference.bolton_key).to eq reference_params[:bolton_key]
      expect(reference.public_notes).to eq reference_params[:public_notes]
      expect(reference.editor_notes).to eq reference_params[:editor_notes]
      expect(reference.taxonomic_notes).to eq reference_params[:taxonomic_notes]
    end

    it 'creates an activity' do
      expect { post(:create, params: params.merge(edit_summary: 'edited')) }.
        to change { Activity.where(event: Activity::CREATE).count }.by(1)

      activity = Activity.last
      reference = Reference.last
      expect(activity.trackable).to eq reference
      expect(activity.edit_summary).to eq "edited"
      expect(activity.parameters).to eq(name: "Batiatus & Glaber, 1999b")
    end
  end

  describe "PUT update", as: :helper do
    let!(:reference) { create :article_reference, :with_author_name }
    let!(:reference_params) do
      {
        title: 'Newer Ants',
        author_names_string: reference.author_names_string,
        journal_name: reference.journal.name,
        online_early: true,
        pagination: '5'
      }
    end
    let!(:params) do
      {
        reference_type: reference.type,
        id: reference.id,
        reference: reference_params
      }
    end

    it 'updates the reference' do
      expect { put(:update, params: params) }.
        to change { reference.reload.title }.to(reference_params[:title]).
        and change { reference.online_early }.from(false).to(true)
    end

    it 'creates an activity' do
      expect { put(:update, params: params.merge(edit_summary: 'edited')) }.
        to change { Activity.where(event: Activity::UPDATE, trackable: reference).count }.by(1)

      activity = Activity.last
      expect(activity.edit_summary).to eq 'edited'
      expect(activity.parameters).to eq(name: reference.key_with_suffixed_year)
    end
  end

  describe "DELETE destroy", as: :editor do
    let!(:reference) { create :any_reference, :with_author_name }

    it 'deletes the reference' do
      expect { delete(:destroy, params: { id: reference.id }) }.to change { Reference.count }.by(-1)
    end

    it 'creates an activity' do
      reference_key = reference.key_with_suffixed_year

      expect { delete(:destroy, params: { id: reference.id }) }.
        to change { Activity.where(event: Activity::DESTROY, trackable: reference).count }.by(1)

      activity = Activity.last
      expect(activity.parameters).to eq(name: reference_key)
    end
  end
end
