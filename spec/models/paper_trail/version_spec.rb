# frozen_string_literal: true

require 'rails_helper'

describe PaperTrail::Version do
  describe 'relations' do
    describe "#activity" do
      context 'when version is associated with an `Activity`' do
        let!(:request_uuid) { '999' }
        let!(:activity) { create :activity }
        let!(:version) { create :version }

        before do
          # HACK: To please `SetRequestUuid`. Probably fix.
          version.update!(request_uuid: request_uuid)
        end

        specify do
          expect { activity.update!(request_uuid: request_uuid) }.
            to change { version.reload.activity }.from(nil).to(activity)
        end
      end
    end

    describe "#user" do
      context 'when version has a whodunnit' do
        let!(:user) { create :user }
        let!(:version) { build_stubbed :version, whodunnit: user.id }

        specify { expect(version.user).to eq user }
      end

      context 'when version does not have a whodunnit' do
        let!(:version) { build_stubbed :version, whodunnit: nil }

        specify { expect(version.user).to eq nil }
      end
    end
  end

  describe 'callbacks' do
    it_behaves_like "a model that assigns `request_id` on create" do
      let!(:item) { create :user }
      let(:instance) { build :version, item: item }
    end
  end

  describe 'scopes' do
    describe '.chronological' do
      let!(:version_2) { create :version, created_at: 3.years.ago }
      let!(:version_3) { create :version, created_at: version_2.created_at }
      let!(:version_4) { create :version, created_at: 2.years.ago }
      let!(:version_1) { create :version, created_at: 5.years.ago }

      it 'orders by chronological order (most recent `created_at` last, with `id` as a tiebreaker)' do
        expect(described_class.chronological).to eq [version_1, version_2, version_3, version_4]
      end
    end
  end

  describe '.search', :versioning do
    let!(:lasius_item) { create :history_item, :taxt, taxt: "Lasius content" }
    let!(:formica_123_item) { create :history_item, :taxt, taxt: "Formica content 123" }

    context "with search type 'LIKE'" do
      specify do
        versions = described_class.search('lasius', 'LIKE')

        expect(versions.map(&:item_type)).to eq ["HistoryItem"]
        expect(versions.map(&:item_id)).to eq [lasius_item.id]
      end
    end

    context "with search type 'REGEXP'" do
      specify do
        versions = described_class.search('content [0-9]', 'REGEXP')

        expect(versions.map(&:item_type)).to eq ["HistoryItem"]
        expect(versions.map(&:item_id)).to eq [formica_123_item.id]
      end
    end

    context "with unknown search type" do
      specify do
        expect { described_class.search('cont', 'PIZZA') }.to raise_error("unknown search_type PIZZA")
      end
    end
  end

  describe '#safe_reify', :versioning do
    let(:reference) { create :article_reference }

    it 'safely reifies specific STI classes' do
      reference.update!(title: 'updated to create a version')

      version = reference.versions.last
      version.update_columns(object: version.object.gsub('ArticleReference', 'MissingReference'))

      expect { version.reify }.to raise_error(ActiveRecord::SubclassNotFound)

      expect(version.safe_reify).to be_a(Reference)
    end
  end
end
