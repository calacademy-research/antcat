# frozen_string_literal: true

require 'rails_helper'

describe ApplicationController do
  describe '#set_current_request_uuid' do
    let!(:request_uuid) { SecureRandom.uuid }
    let!(:protonym) { create :protonym }
    let(:params) do
      {
        protonym: { fossil: false }
      }
    end

    before do
      allow(SecureRandom).to receive(:uuid).and_return(request_uuid)
      sign_in create(:user, :helper)
    end

    it 'assigns `request_uuid` to activities' do
      expect { put protonym_path(protonym), params: params }.to change { Activity.count }

      activity = Activity.last
      expect(activity.request_uuid).to eq request_uuid
    end

    it 'assigns `request_uuid` to versions', :versioning do
      expect { put protonym_path(protonym), params: params }.to change { PaperTrail::Version.count }

      version = PaperTrail::Version.last
      expect(version.request_uuid).to eq request_uuid
    end
  end
end
