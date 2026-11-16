# frozen_string_literal: true

require 'rails_helper'

describe Protonyms::NotesController do
  describe "forbidden actions" do
    context "when not signed in", as: :visitor do
      specify { expect(get(:new, params: { protonym_id: 1 })).to redirect_to_signin_form }
      specify { expect(get(:edit, params: { protonym_id: 1 })).to redirect_to_signin_form }
      specify { expect(post(:create, params: { protonym_id: 1 })).to redirect_to_signin_form }
      specify { expect(put(:update, params: { protonym_id: 1 })).to redirect_to_signin_form }
      specify { expect(delete(:destroy, params: { protonym_id: 1 })).to redirect_to_signin_form }
    end

    context "when signed in as a user who is not a helper or editor", as: :user do
      specify { expect(get(:new, params: { protonym_id: 1 })).to have_http_status :forbidden }
      specify { expect(post(:create, params: { protonym_id: 1 })).to have_http_status :forbidden }
      specify { expect(get(:edit, params: { protonym_id: 1 })).to have_http_status :forbidden }
      specify { expect(put(:update, params: { protonym_id: 1 })).to have_http_status :forbidden }
      specify { expect(delete(:destroy, params: { protonym_id: 1 })).to have_http_status :forbidden }
    end

    context "when signed in as a helper", as: :helper do
      specify { expect(delete(:destroy, params: { protonym_id: 1 })).to have_http_status :forbidden }
    end
  end

  describe "GET show", as: :visitor do
    let!(:notes_page) { create :notes_page }

    specify { expect(get(:show, params: { protonym_id: notes_page.protonym_id })).to render_template :show }

    it 'answers "not found" for a name without notes' do
      protonym = create :protonym

      expect { get(:show, params: { protonym_id: protonym.id }) }.to raise_error(ActiveRecord::RecordNotFound)
    end
  end

  describe "GET new", as: :helper do
    let!(:protonym) { create :protonym }

    specify { expect(get(:new, params: { protonym_id: protonym.id })).to render_template :new }

    it 'goes to the edit form when the name has notes already' do
      create :notes_page, protonym: protonym

      expect(get(:new, params: { protonym_id: protonym.id })).to redirect_to edit_protonym_notes_path(protonym)
    end
  end

  describe "POST create", as: :helper do
    let!(:protonym) { create :protonym, :genus_group }
    let!(:notes_page_params) { { content: "## Type specimen notes\n\nText." } }

    it 'creates the page of notes of the protonym, of any rank' do
      expect { post(:create, params: { protonym_id: protonym.id, notes_page: notes_page_params }) }.
        to change { NotesPage.count }.by(1)

      expect(protonym.reload.notes_page.content).to eq notes_page_params[:content]
      expect(response).to redirect_to protonym_notes_path(protonym)
    end

    it 'creates an activity' do
      expect { post(:create, params: { protonym_id: protonym.id, notes_page: notes_page_params, edit_summary: 'add notes' }) }.
        to change { Activity.where(event: Activity::CREATE).count }.by(1)

      activity = Activity.last
      expect(activity.trackable).to eq protonym.reload.notes_page
      expect(activity.edit_summary).to eq "add notes"
      expect(activity.parameters).to eq(protonym_id: protonym.id, protonym_name: protonym.name.name)
    end

    it 'does not add a second page' do
      create :notes_page, protonym: protonym

      expect { post(:create, params: { protonym_id: protonym.id, notes_page: notes_page_params }) }.
        not_to change { NotesPage.count }
      expect(response).to redirect_to edit_protonym_notes_path(protonym)
    end

    it 'goes to the edit form when someone else added the notes at the same moment' do
      allow_any_instance_of(NotesPage).to receive(:save).and_raise(ActiveRecord::RecordNotUnique) # rubocop:disable RSpec/AnyInstance

      expect(post(:create, params: { protonym_id: protonym.id, notes_page: notes_page_params })).
        to redirect_to edit_protonym_notes_path(protonym)
    end

    it 'shows the form again when the notes are empty' do
      expect(post(:create, params: { protonym_id: protonym.id, notes_page: { content: '' } })).to render_template :new
    end
  end

  describe "GET edit", as: :helper do
    let!(:notes_page) { create :notes_page }

    specify { expect(get(:edit, params: { protonym_id: notes_page.protonym_id })).to render_template :edit }
  end

  describe "PUT update", as: :helper do
    let!(:notes_page) { create :notes_page }

    it 'updates the notes' do
      put(:update, params: { protonym_id: notes_page.protonym_id, notes_page: { content: 'new content' } })

      expect(notes_page.reload.content).to eq 'new content'
      expect(response).to redirect_to protonym_notes_path(notes_page.protonym)
    end

    it 'creates an activity' do
      expect { put(:update, params: { protonym_id: notes_page.protonym_id, notes_page: { content: 'new' }, edit_summary: 'fix' }) }.
        to change { Activity.where(event: Activity::UPDATE, trackable: notes_page).count }.by(1)
    end
  end

  describe "DELETE destroy", as: :editor do
    let!(:notes_page) { create :notes_page }

    it 'deletes the notes and keeps the protonym' do
      protonym = notes_page.protonym

      expect { delete(:destroy, params: { protonym_id: protonym.id }) }.to change { NotesPage.count }.by(-1)
      expect(response).to redirect_to protonym_path(protonym)
      expect(Protonym.exists?(protonym.id)).to eq true
    end

    it 'creates an activity' do
      expect { delete(:destroy, params: { protonym_id: notes_page.protonym_id }) }.
        to change { Activity.where(event: Activity::DESTROY, trackable_type: 'NotesPage').count }.by(1)
    end
  end
end
