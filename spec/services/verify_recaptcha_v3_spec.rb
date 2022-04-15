# frozen_string_literal: true

require 'rails_helper'

describe VerifyRecaptchaV3 do
  subject(:service) { described_class.new('pizza123', recaptcha_action) }

  let(:recaptcha_action) { 'order_pizza_action' }
  let(:url) { "https://www.google.com/recaptcha/api/siteverify?response=pizza123&secret=test_secret_key" }
  let(:response_score) { Settings.recaptcha.v3.minimum_score + 0.1 } # Default to above minimum.
  let(:response_action) { recaptcha_action }

  before do
    body =
      {
        "success" => response_success,
        "score" => response_score,
        "action" => response_action
      }.to_json
    stub_request(:get, url).to_return(status: 200, body: body)
  end

  describe '#call' do
    context 'with unsuccessful response' do
      let(:response_success) { false }

      specify { expect(service.call).to eq false }
    end

    context 'with successful response' do
      let(:response_success) { true }

      context 'with score above minimum score' do
        context 'with correct action' do
          specify { expect(service.call).to eq true }
        end

        context 'with incorrect action' do
          let(:response_action) { 'incorrect_action' }

          specify { expect(service.call).to eq false }
        end
      end

      context 'with score below minimum score' do
        let(:response_score) { Settings.recaptcha.v3.minimum_score - 0.1 }

        specify { expect(service.call).to eq false }
      end
    end
  end
end
