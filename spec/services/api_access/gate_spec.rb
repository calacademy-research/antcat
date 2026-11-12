# frozen_string_literal: true

require 'rails_helper'

describe ApiAccess::Gate do
  let(:now) { Time.utc(2026, 11, 8, 12, 30, 15) }
  let(:ip) { '203.0.113.7' }

  def gate api_key: nil, at: now, from: ip
    described_class.new(api_key: api_key, ip: from, now: at)
  end

  describe 'without a key' do
    it 'allows 5 requests a minute per IP, then answers with the seconds left in the minute' do
      5.times { expect(gate.admit).to be_nil }

      rejection = gate.admit
      expect(rejection.limit_name).to eq :requests_per_minute
      expect(rejection.limit).to eq 5
      expect(rejection.retry_after).to eq 45

      expect(gate(at: now + 45.seconds).admit).to be_nil
    end

    # Each request makes a new gate, like requests landing on either Puma worker: the counts are in the
    # database, so they are shared.
    it 'counts per IP' do
      5.times { gate.admit }
      expect(gate.admit).to be_present
      expect(gate(from: '198.51.100.1').admit).to be_nil
    end

    it 'allows 50 requests a day, then answers with the seconds until midnight UTC' do
      50.times { |i| expect(gate(at: now + (i * 61).seconds).admit).to be_nil }

      later = now + 1.hour + 5.minutes
      rejection = gate(at: later).admit
      expect(rejection.limit_name).to eq :requests_per_day
      expect(rejection.retry_after).to eq((Time.utc(2026, 11, 9) - later).to_i)

      expect(gate(at: now + 1.day).admit).to be_nil
    end

    # Two requests at the same moment (one in each Puma worker) both look at the day's count before
    # either is counted. The count is one statement that also checks the limit, so only one gets through.
    it 'never counts more requests than the daily limit' do
      49.times { |i| gate(at: now + (i * 61).seconds).admit }
      later = now + 1.hour
      first = gate(at: later)
      second = gate(at: later + 1.second)
      [first, second].each { |each_gate| expect(each_gate.__send__(:daily_rejection)).to be_nil }

      expect(first.admit).to be_nil
      rejection = second.admit

      expect(rejection.limit_name).to eq :requests_per_day
      expect(rejection.limit).to eq 50
      expect(ApiUsageDay.sole).to have_attributes(requests: 50, rejected: 1)
    end

    it 'stores a hash of the IP, never the IP' do
      gate.admit

      usage = ApiUsageDay.sole
      expect(usage.api_key_id).to eq ApiAccess::NO_KEY_ID
      expect(usage.client).to eq ApiAccess.ip_hash(ip, now.to_date)
      expect(usage.client).not_to include ip
      expect(ApiUsageMinute.pluck(:client)).not_to include ip
    end

    it 'hashes the same IP differently on different days' do
      expect(ApiAccess.ip_hash(ip, now.to_date)).not_to eq ApiAccess.ip_hash(ip, now.to_date + 1)
    end

    it 'counts refused requests' do
      6.times { gate.admit }
      expect(ApiUsageDay.sole).to have_attributes(requests: 5, rejected: 1)
    end
  end

  describe 'with a key' do
    let(:api_key) { create(:api_key).tap(&:issue_key!) }

    it 'allows 60 requests a minute and counts them for the key' do
      60.times { expect(gate(api_key: api_key).admit).to be_nil }
      expect(gate(api_key: api_key).admit.limit).to eq 60

      expect(ApiUsageDay.sole).to have_attributes(api_key_id: api_key.id, client: "", requests: 60, rejected: 1)
      expect(api_key.reload.last_used_at).to eq now
    end

    it 'uses per-key limits' do
      api_key.update!(requests_per_minute: 2)
      2.times { expect(gate(api_key: api_key).admit).to be_nil }
      expect(gate(api_key: api_key).admit.limit).to eq 2
    end

    it 'stops at the daily records limit, and the last page is cut to what is left' do
      api_key.update!(records_per_day: 250)

      gate(api_key: api_key).add_records 200
      expect(gate(api_key: api_key).records_per_page).to eq 50

      gate(api_key: api_key).add_records 50
      rejection = gate(api_key: api_key).admit
      expect(rejection.limit_name).to eq :records_per_day
      expect(rejection.limit).to eq 250
    end
  end

  describe 'records per page' do
    it 'is 25 without a key and 100 with a key' do
      expect(gate.records_per_page).to eq 25
      expect(gate(api_key: create(:api_key)).records_per_page).to eq 100
    end
  end
end
