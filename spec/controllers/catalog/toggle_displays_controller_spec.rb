require 'rails_helper'

describe Catalog::ToggleDisplaysController do
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
  end
end
