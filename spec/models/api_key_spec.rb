# frozen_string_literal: true

require 'rails_helper'

describe ApiKey do
  describe 'validations' do
    it 'needs a name, an email, a project and the terms' do
      api_key = described_class.new
      expect(api_key).not_to be_valid
      expect(api_key.errors.attribute_names).to include(:name, :email, :project, :terms)
    end

    it 'does not need an institution' do
      expect(build(:api_key, institution: nil)).to be_valid
    end

    it 'checks the email format' do
      expect(build(:api_key, email: 'not an email')).not_to be_valid
    end

    it 'does not accept per-key limits above the maximums' do
      api_key = build :api_key, records_per_page: ApiAccess::MAX_RECORDS_PER_PAGE + 1,
        requests_per_minute: ApiAccess::MAX_REQUESTS_PER_MINUTE + 1
      expect(api_key).not_to be_valid
      expect(api_key.errors.attribute_names).to include(:records_per_page, :requests_per_minute)
    end

    it 'stores when the terms were accepted' do
      expect(create(:api_key).terms_accepted_at).to be_present
    end
  end

  describe '#issue_key!' do
    let(:api_key) { create :api_key, confirmation_digest: 'x' * 64 }

    it 'returns an "ac_" key and stores only its digest and prefix' do
      key = api_key.issue_key!

      expect(key).to match(/\Aac_[1-9A-HJ-NP-Za-km-z]{#{described_class::KEY_RANDOM_LENGTH}}\z/)
      api_key.reload
      expect(api_key.key_digest).to eq OpenSSL::Digest::SHA256.hexdigest(key)
      expect(api_key.key_prefix).to eq key.first(described_class::KEY_DISPLAY_LENGTH)
      expect(api_key.attributes.values.map(&:to_s)).not_to include key
      expect(api_key.status).to eq described_class::ACTIVE
      expect(api_key.confirmation_digest).to be_nil
    end

    it 'issues a key only once' do
      api_key.issue_key!
      expect(api_key.issue_key!).to be_nil
    end
  end

  describe '.find_active_by_key' do
    let(:api_key) { create :api_key }
    let!(:key) { api_key.issue_key! }

    it 'finds active keys only' do
      expect(described_class.find_active_by_key(key)).to eq api_key

      api_key.revoke!
      expect(described_class.find_active_by_key(key)).to be_nil

      api_key.reactivate!
      expect(described_class.find_active_by_key(key)).to eq api_key
    end

    it 'ignores values that are not keys' do
      expect(described_class.find_active_by_key(nil)).to be_nil
      expect(described_class.find_active_by_key(key.delete_prefix('ac_'))).to be_nil
      expect(described_class.find_active_by_key("#{key}x")).to be_nil
    end
  end

  describe '.find_pending_by_confirmation_token' do
    let(:api_key) { build :api_key }
    let!(:token) { api_key.new_confirmation_token.tap { api_key.save! } }

    it 'finds the registration while the link is valid' do
      expect(api_key.confirmation_digest).not_to eq token
      expect(described_class.find_pending_by_confirmation_token(token)).to eq api_key

      travel described_class::CONFIRMATION_VALID_FOR + 1.minute do
        expect(described_class.find_pending_by_confirmation_token(token)).to be_nil
      end
    end
  end

  describe '#reactivate!' do
    it 'does not reactivate a registration that never got a key' do
      api_key = create :api_key
      api_key.revoke!
      expect(api_key.reactivate!).to be false
      expect(api_key.reload.status).to eq described_class::REVOKED
    end
  end

  describe '#limits' do
    it 'uses the level limits, with per-key values where set' do
      api_key = build :api_key
      expect(api_key.limits).to eq ApiAccess::REGISTERED_LIMITS

      api_key.assign_attributes(level: described_class::COLLABORATOR, requests_per_day: 20_000, records_per_page: 500)
      expect(api_key.limits).to have_attributes(
        requests_per_minute: 60, requests_per_day: 20_000, records_per_page: 500, records_per_day: 50_000
      )

      api_key.level = described_class::ADMIN
      expect(api_key.limits.records_per_day).to be_nil
    end
  end
end
