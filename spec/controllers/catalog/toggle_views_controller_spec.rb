# frozen_string_literal: true

require 'rails_helper'

describe Catalog::ToggleViewsController do
  describe "PUT update", as: :visitor do
    before do
      create :family
      request.env["HTTP_REFERER"] = "https://antcat.org"
    end

    context 'when `valid_only`' do
      specify do
        expect { put :update, params: { show: 'valid_only' } }.
          to change { session[:show_invalid] }.to(false)
      end
    end

    context 'when `valid_and_invalid`' do
      specify do
        expect { put :update, params: { show: 'valid_and_invalid' } }.
          to change { session[:show_invalid] }.to(true)
      end
    end

    context 'when the value is unknown' do
      specify do
        put :update, params: { show: 'pizza' }
        expect(response).to have_http_status :bad_request
        expect(session[:show_invalid]).to be_nil
      end
    end
  end
end
