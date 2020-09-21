# frozen_string_literal: true

require 'rails_helper'

describe ReferenceSection do
  it { is_expected.to be_versioned }

  describe 'relations' do
    it { is_expected.to belong_to(:taxon).required }
  end

  describe 'callbacks' do
    it { is_expected.to strip_attributes(:title_taxt, :subtitle_taxt, :references_taxt) }

    it_behaves_like "a taxt column with cleanup", :references_taxt do
      subject { build :reference_section }
    end

    it_behaves_like "a taxt column with cleanup", :subtitle_taxt do
      subject { build :reference_section }
    end

    it_behaves_like "a taxt column with cleanup", :title_taxt do
      subject { build :reference_section }
    end
  end

  describe '.search' do
    let!(:lasius_item) { create :reference_section, references_taxt: "Lasius content" }
    let!(:formica_123_item) { create :reference_section, references_taxt: "Formica content 123" }

    context "with search type 'LIKE'" do
      specify do
        expect(described_class.search('cont', 'LIKE')).to match_array [lasius_item, formica_123_item]
        expect(described_class.search('lasius', 'LIKE')).to match_array [lasius_item]
        expect(described_class.search('content \d\d\d', 'LIKE')).to match_array []
      end
    end

    context "with search type 'REGEXP'" do
      specify do
        expect(described_class.search('cont', 'REGEXP')).to match_array [lasius_item, formica_123_item]
        expect(described_class.search('lasius', 'REGEXP')).to match_array [lasius_item]
        expect(described_class.search('content [0-9]', 'REGEXP')).to match_array [formica_123_item]
      end
    end

    context "with unknown search type" do
      specify do
        expect { described_class.search('cont', 'PIZZA') }.to raise_error("unknown search_type PIZZA")
      end
    end
  end
end
