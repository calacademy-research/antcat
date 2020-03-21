require 'rails_helper'

describe TooltipsController do
  describe "forbidden actions" do
    context "when signed in as a user", as: :user do
      specify { expect(get(:new)).to have_http_status :forbidden }
      specify { expect(get(:show, params: { id: 1 })).to have_http_status :forbidden }
      specify { expect(get(:edit, params: { id: 1 })).to have_http_status :forbidden }
      specify { expect(post(:create)).to have_http_status :forbidden }
      specify { expect(put(:update, params: { id: 1 })).to have_http_status :forbidden }
    end

    context "when signed in as an editor", as: :editor do
      specify { expect(delete(:destroy, params: { id: 1 })).to have_http_status :forbidden }
    end
  end

  describe "POST create", as: :helper do
    let!(:tooltip_params) do
      {
        key: 'pagination',
        scope: 'references',
        text: 'Help text'
      }
    end

    it 'creates a tooltip' do
      expect { post(:create, params: { tooltip: tooltip_params }) }.to change { Tooltip.count }.by(1)

      tooltip = Tooltip.last
      expect(tooltip.key).to eq tooltip_params[:key]
      expect(tooltip.scope).to eq tooltip_params[:scope]
      expect(tooltip.text).to eq tooltip_params[:text]
    end

    it 'creates an activity' do
      expect { post(:create, params: { tooltip: tooltip_params }) }.
        to change { Activity.where(action: :create).count }.by(1)

      activity = Activity.last
      tooltip = Tooltip.last
      expect(activity.trackable).to eq tooltip
      expect(activity.parameters).to eq(scope_and_key: "#{tooltip.scope}.#{tooltip.key}")
    end
  end

  describe "PUT update", as: :helper do
    let!(:tooltip) { create :tooltip }
    let!(:tooltip_params) do
      {
        key: 'pagination',
        scope: 'references',
        text: 'Help text'
      }
    end

    it 'updates the tooltip' do
      put(:update, params: { id: tooltip.id, tooltip: tooltip_params })

      tooltip.reload
      expect(tooltip.key).to eq tooltip_params[:key]
      expect(tooltip.scope).to eq tooltip_params[:scope]
      expect(tooltip.text).to eq tooltip_params[:text]
    end
  end

  describe "DELETE destroy", as: :current_user do
    let(:current_user) { create(:user, :superadmin, :editor) }
    let!(:tooltip) { create :tooltip }

    it 'deletes the tooltip' do
      expect { delete(:destroy, params: { id: tooltip.id }) }.to change { Tooltip.count }.by(-1)
    end

    it 'creates an activity' do
      expect { delete(:destroy, params: { id: tooltip.id }) }.
        to change { Activity.where(action: :destroy, trackable: tooltip).count }.by(1)

      activity = Activity.last
      expect(activity.parameters).to eq(scope_and_key: "#{tooltip.scope}.#{tooltip.key}")
    end
  end
end
