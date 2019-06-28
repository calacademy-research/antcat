require 'spec_helper'

describe Catalog::ToggleDisplaysController do
  describe "PUT update" do
    before do
      create :family
      @request.env["HTTP_REFERER"] = "http://antcat.org"
    end

    context 'when `valid_only`' do
      before { put :update, params: { show: 'valid_only' } }

      it { is_expected.to set_session[:show_invalid].to false }
    end

    context 'when `valid_and_invalid`' do
      before { put :update, params: { show: 'valid_and_invalid' } }

      it { is_expected.to set_session[:show_invalid].to true }
    end
  end
end
