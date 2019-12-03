require 'rails_helper'

describe Taxa::Search::SingleMatchToRedirectTo do
  describe "#call" do
    let!(:exact_match) { create :species, name_string: 'Lasius niger' }

    context "when search query is blank" do
      specify { expect(described_class['']).to eq nil }
    end

    context 'when there no exact matches' do
      specify { expect(described_class['Formica']).to eq nil }
    end

    context "when there is a single exact match for the name" do
      specify { expect(described_class['Lasius niger']).to eq exact_match }
    end

    context "when there is a single exact match for the epithet" do
      specify { expect(described_class['niger']).to eq exact_match }
    end

    context 'when there are more than one exact match for the name' do
      specify do
        expect { create :species, name_string: exact_match.name.name }.
          to change { described_class['Lasius niger'] }.from(exact_match).to(nil)
      end
    end

    context 'when there is more than one exact match for the epithet' do
      specify do
        expect { create :species, name_string: exact_match.name.name }.
          to change { described_class['niger'] }.from(exact_match).to(nil)
      end
    end
  end
end
