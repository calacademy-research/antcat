# frozen_string_literal: true

require 'rails_helper'

describe Users::ScrubSensitiveVersionData do
  let(:user) { create :user }
  let!(:version) do
    PaperTrail::Version.create!(
      item_type: 'User',
      item_id: user.id,
      event: PaperTrail::Version::UPDATE,
      object: PaperTrail.serializer.dump(
        'id' => user.id, 'name' => 'Old name', 'encrypted_password' => 'hash', 'reset_password_token' => 'token'
      ),
      object_changes: PaperTrail.serializer.dump(
        'name' => ['Old name', 'New name'], 'remember_token' => [nil, 'token']
      )
    )
  end

  it 'does not store sensitive columns in new versions' do
    with_versioning do
      user.update!(name: 'Another name', password: 'newsecret123', reset_password_token: 'abc')
    end

    new_version = PaperTrail::Version.where(item_type: 'User', item_id: user.id).where.not(id: version.id).last
    expect(new_version.object).not_to include('encrypted_password', 'reset_password_token')
    expect(new_version.object_changes).not_to include('encrypted_password', 'reset_password_token')
  end

  context 'when dry run (default)' do
    it 'reports counts without changing anything' do
      counts = described_class[]

      expect(counts[:affected]).to eq 1
      expect(counts[:removed_keys]).to eq('encrypted_password' => 1, 'reset_password_token' => 1, 'remember_token' => 1)
      expect(version.reload.object).to include('encrypted_password')
    end
  end

  context 'when not a dry run' do
    it 'removes sensitive keys and keeps the rest' do
      described_class[dry_run: false]

      version.reload
      object = PaperTrail.serializer.load(version.object)
      object_changes = PaperTrail.serializer.load(version.object_changes)
      expect(object).to eq('id' => user.id, 'name' => 'Old name')
      expect(object_changes).to eq('name' => ['Old name', 'New name'])
    end

    it 'leaves versions of other item types alone' do
      other = PaperTrail::Version.create!(
        item_type: 'WikiPage', item_id: 1, event: PaperTrail::Version::UPDATE,
        object: PaperTrail.serializer.dump('encrypted_password' => 'x')
      )

      described_class[dry_run: false]
      expect(other.reload.object).to include('encrypted_password')
    end
  end
end
