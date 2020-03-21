require 'rails_helper'

describe InstitutionsController do
  describe "forbidden actions" do
    context "when signed in as a user", as: :user do
      specify { expect(get(:new)).to have_http_status :forbidden }
      specify { expect(get(:edit, params: { id: 1 })).to have_http_status :forbidden }
      specify { expect(post(:create)).to have_http_status :forbidden }
      specify { expect(put(:update, params: { id: 1 })).to have_http_status :forbidden }
      specify { expect(delete(:destroy, params: { id: 1 })).to have_http_status :forbidden }
    end

    context "when signed in as a helper editor", as: :helper do
      specify { expect(get(:edit, params: { id: 1 })).to have_http_status :forbidden }
      specify { expect(put(:update, params: { id: 1 })).to have_http_status :forbidden }
      specify { expect(delete(:destroy, params: { id: 1 })).to have_http_status :forbidden }
    end

    context "when signed in as an editor", as: :editor do
      specify { expect(delete(:destroy, params: { id: 1 })).to have_http_status :forbidden }
    end
  end

  describe "GET index", as: :visitor do
    specify { expect(get(:index)).to render_template :index }
  end

  describe "GET show", as: :visitor do
    let!(:institution) { create :institution }

    specify { expect(get(:show, params: { id: institution.id })).to render_template :show }
  end

  describe "GET new", as: :helper do
    specify { expect(get(:new)).to render_template :new }
  end

  describe "POST create", as: :helper do
    let!(:institution_params) do
      {
        abbreviation: 'ABBRV',
        name: 'name'
      }
    end

    it 'creates a institution' do
      expect { post(:create, params: { institution: institution_params }) }.to change { Institution.count }.by(1)

      institution = Institution.last
      expect(institution.abbreviation).to eq institution_params[:abbreviation]
      expect(institution.name).to eq institution_params[:name]
    end

    it 'creates an activity' do
      expect { post(:create, params: { institution: institution_params }) }.
        to change { Activity.where(action: :create).count }.by(1)

      activity = Activity.last
      institution = Institution.last
      expect(activity.trackable).to eq institution
      expect(activity.parameters).to eq(abbreviation: institution.abbreviation)
    end
  end

  describe "GET edit", as: :editor do
    let!(:institution) { create :institution }

    specify { expect(get(:edit, params: { id: institution.id })).to render_template :edit }
  end

  describe "PUT update", as: :editor do
    let!(:institution) { create :institution }
    let!(:institution_params) do
      {
        abbreviation: 'new ABBRV',
        name: 'new name'
      }
    end

    it 'updates the institution' do
      put(:update, params: { id: institution.id, institution: institution_params })

      institution.reload
      expect(institution.abbreviation).to eq institution_params[:abbreviation]
      expect(institution.name).to eq institution_params[:name]
    end
  end

  describe "DELETE destroy", as: :current_user do
    let(:current_user) { create(:user, :superadmin, :editor) }
    let!(:institution) { create :institution }

    it 'deletes the institution' do
      expect { delete(:destroy, params: { id: institution.id }) }.to change { Institution.count }.by(-1)
    end

    it 'creates an activity' do
      expect { delete(:destroy, params: { id: institution.id }) }.
        to change { Activity.where(action: :destroy, trackable: institution).count }.by(1)

      activity = Activity.last
      expect(activity.parameters).to eq(abbreviation: institution.abbreviation)
    end
  end
end
