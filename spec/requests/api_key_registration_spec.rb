# frozen_string_literal: true

require 'rails_helper'

describe "Registering for a free API key" do
  let(:deliveries) { ActionMailer::Base.deliveries }
  let(:form) do
    {
      name: 'Quintus Batiatus',
      email: 'quintus@example.org',
      institution: 'Capua Museum',
      project: 'Names for a checklist of the ants of Campania.',
      terms: '1'
    }
  end

  before { deliveries.clear }

  def register **changes
    post api_keys_path, params: { api_key: form.merge(changes) }
  end

  def token_from_last_email
    deliveries.last.body.decoded[%r{http://antcat\.local/api_keys/confirm\?token=([^"\s&]+)}, 1].
      then { |token| CGI.unescape(CGI.unescapeHTML(token)) }
  end

  context "when API keys are off" do
    it "answers 404" do
      get new_api_key_path
      expect(response).to have_http_status :not_found

      expect { register }.not_to change { ApiKey.count }
      expect(response).to have_http_status :not_found
    end
  end

  context "when API keys are on" do
    before { Settings.api_keys.enabled = true }

    it "shows the form with the terms and links to them" do
      get new_api_key_path

      expect(response).to have_http_status :ok
      expect(response.body).to include "I agree to the terms of use", "/llms.txt", 'href="/v1"'
      expect(response.body).to include Api::V1::RootController::KEY_TERMS.first
    end

    it "needs the name, email, project and the terms box; institution is optional" do
      expect { register name: '', project: '', terms: '0', institution: '' }.not_to change { ApiKey.count }

      expect(response).to have_http_status :unprocessable_content
      expect(CGI.unescapeHTML(response.body)).to include "Name can't be blank", "Project can't be blank",
        "Terms must be accepted"
      expect(deliveries).to be_empty
    end

    it "emails a link, then shows the key once, and emails a copy (without the key) to Brian" do
      expect { register }.to change { ApiKey.count }.by(1)
      expect(response).to redirect_to new_api_key_path
      expect(flash[:notice]).to eq ApiKeysController::EMAIL_SENT_MESSAGE

      api_key = ApiKey.last
      expect(api_key).to have_attributes(status: ApiKey::PENDING, level: ApiKey::REGISTERED, key_digest: nil)

      confirmation_email = deliveries.sole
      expect(confirmation_email.to).to eq ['quintus@example.org']
      expect(confirmation_email.body.decoded).not_to include 'Quintus', 'Campania'
      token = token_from_last_email
      expect(api_key.confirmation_digest).to eq ApiKey.digest(token)

      # The link opens a page with a button; opening it does not use it up.
      get confirm_api_key_path(token: token)
      expect(response).to have_http_status :ok
      get confirm_api_key_path(token: token)
      expect(response.body).to include "Show my API key"
      expect(api_key.reload.status).to eq ApiKey::PENDING

      post issue_api_key_path, params: { token: token }
      expect(response).to have_http_status :ok
      expect(response.headers['Cache-Control']).to include 'no-store'
      key = response.body[/ac_[1-9A-HJ-NP-Za-km-z]{#{ApiKey::KEY_RANDOM_LENGTH}}/o]
      expect(key).to be_present
      expect(ApiKey.find_active_by_key(key)).to eq api_key

      copy = deliveries.last
      expect(copy.to).to eq [Settings.api_keys.registration_copy_to]
      expect(copy.to).to eq ['bfisher@calacademy.org']
      expect(copy.body.decoded).to include 'Quintus Batiatus', 'quintus@example.org', 'Campania', api_key.reload.key_prefix
      expect(copy.body.decoded).not_to include key

      # Shown once: the link does not work again.
      post issue_api_key_path, params: { token: token }
      expect(response).to redirect_to new_api_key_path
      expect(flash[:alert]).to eq ApiKeysController::INVALID_LINK_MESSAGE
      expect(response.body).not_to include key
    end

    it "does not accept an expired link" do
      register
      token = token_from_last_email

      travel ApiKey::CONFIRMATION_VALID_FOR + 1.minute do
        get confirm_api_key_path(token: token)
        expect(response).to redirect_to new_api_key_path

        post issue_api_key_path, params: { token: token }
        expect(response).to redirect_to new_api_key_path
      end
      expect(ApiKey.last.status).to eq ApiKey::PENDING
    end

    it "does not accept a made-up link" do
      post issue_api_key_path, params: { token: 'made-up' }
      expect(response).to redirect_to new_api_key_path
    end

    it "is throttled per IP and email" do
      allow(Rails.cache).to receive(:increment).and_call_original
      allow(Rails.cache).to receive(:increment).
        with("api_key:ip:127.0.0.1", any_args).and_return(ApiKeysController::REGISTRATIONS_PER_IP + 1)

      expect { register }.not_to change { ApiKey.count }
      expect(response).to redirect_to new_api_key_path
      expect(flash[:alert]).to eq ApiKeysController::TOO_MANY_REGISTRATIONS_MESSAGE
    end
  end
end
