# frozen_string_literal: true

require 'rails_helper'

describe ApplicationController, as: :visitor do
  include HttpBasicAuthHelpers

  context 'when HTTP Basic Auth is enabled' do
    before do
      Settings.http_basic_auth.enabled = true
    end

    controller(described_class) do
      def index
        render plain: "OK!"
      end
    end

    context 'with invalid credentials' do
      specify { expect(get(:index)).to have_http_status :unauthorized }
    end

    context 'with valid credentials' do
      before do
        with_valid_http_basic_auth_credentials!
      end

      specify { expect(get(:index)).to have_http_status :ok }
    end
  end
end
