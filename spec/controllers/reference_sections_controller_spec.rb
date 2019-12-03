require 'rails_helper'

describe ReferenceSectionsController do
  describe "forbidden actions" do
    context "when signed in as a user" do
      before { sign_in create(:user) }

      specify { expect(get(:new, params: { taxa_id: 1 })).to have_http_status :forbidden }
      specify { expect(get(:edit, params: { id: 1 })).to have_http_status :forbidden }
      specify { expect(post(:create, params: { taxa_id: 1 })).to have_http_status :forbidden }
      specify { expect(put(:update, params: { id: 1 })).to have_http_status :forbidden }
    end

    context "when signed in as a helper editor" do
      before { sign_in create(:user, :helper) }

      specify { expect(delete(:destroy, params: { id: 1 })).to have_http_status :forbidden }
    end
  end

  describe "POST create" do
    let!(:taxon) { create :family }
    let!(:reference_section_params) do
      {
        title_taxt: 'title_taxt',
        subtitle_taxt: 'subtitle_taxt',
        references_taxt: 'references_taxt'
      }
    end

    before { sign_in create(:user, :helper) }

    it 'creates a reference section' do
      expect do
        post(:create, params: { taxa_id: taxon.id, reference_section: reference_section_params })
      end.to change { ReferenceSection.count }.by(1)

      reference_section = ReferenceSection.last
      expect(reference_section.title_taxt).to eq reference_section_params[:title_taxt]
      expect(reference_section.subtitle_taxt).to eq reference_section_params[:subtitle_taxt]
      expect(reference_section.references_taxt).to eq reference_section_params[:references_taxt]
    end

    it 'creates a activity' do
      expect do
        post(:create, params: { taxa_id: taxon.id, reference_section: reference_section_params, edit_summary: 'added' })
      end.to change { Activity.where(action: :create).count }.by(1)

      activity = Activity.last
      reference_section = ReferenceSection.last
      expect(activity.trackable).to eq reference_section
      expect(activity.edit_summary).to eq "added"
      expect(activity.parameters).to eq(taxon_id: reference_section.taxon_id)
    end
  end

  describe "PUT update" do
    let!(:reference_section) { create :reference_section }
    let!(:reference_section_params) do
      {
        title_taxt: 'title_taxt',
        subtitle_taxt: 'subtitle_taxt',
        references_taxt: 'references_taxt'
      }
    end

    before { sign_in create(:user, :helper) }

    it 'updates the history item' do
      put(:update, params: { id: reference_section.id, reference_section: reference_section_params })

      reference_section.reload
      expect(reference_section.title_taxt).to eq reference_section_params[:title_taxt]
      expect(reference_section.subtitle_taxt).to eq reference_section_params[:subtitle_taxt]
      expect(reference_section.references_taxt).to eq reference_section_params[:references_taxt]
    end

    it 'creates an activity' do
      expect { put(:update, params: { id: reference_section.id, reference_section: reference_section_params, edit_summary: 'Duplicate' }) }.
        to change { Activity.where(action: :update, trackable: reference_section).count }.by(1)

      activity = Activity.last
      expect(activity.edit_summary).to eq "Duplicate"
      expect(activity.parameters).to eq(taxon_id: reference_section.taxon_id)
    end
  end

  describe "DELETE destroy" do
    let!(:reference_section) { create :reference_section }

    before { sign_in create(:user, :editor) }

    it 'deletes the reference section' do
      expect { delete(:destroy, params: { id: reference_section.id }) }.to change { ReferenceSection.count }.by(-1)
    end

    it 'creates an activity' do
      expect { delete(:destroy, params: { id: reference_section.id, edit_summary: 'Duplicate' }) }.
        to change { Activity.where(action: :destroy, trackable: reference_section).count }.by(1)

      activity = Activity.last
      expect(activity.edit_summary).to eq "Duplicate"
      expect(activity.parameters).to eq(taxon_id: reference_section.taxon_id)
    end
  end
end
