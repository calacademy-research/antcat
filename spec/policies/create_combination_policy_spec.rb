require 'rails_helper'

describe CreateCombinationPolicy do
  subject(:policy) { described_class.new(taxon) }

  describe '#errors' do
    let(:taxon) { build_stubbed :family }

    it 'adds errors on initialization' do
      expect(policy.errors).to eq ["taxon is not a species"]
    end
  end

  describe '#allowed?' do
    context 'when allowed' do
      let(:taxon) { build_stubbed :species }

      specify { expect(policy.allowed?).to eq true }
    end

    context 'when not allowed' do
      let(:taxon) { build_stubbed :family }

      specify { expect(policy.allowed?).to eq false }
    end

    describe 'lazy evaluation' do
      let(:taxon) { create :family }

      it 'stops at the first error' do
        expect(taxon).to_not receive(:soft_validations)
        expect(policy.allowed?).to eq false
      end
    end

    context "when taxon has 'What Links Here's" do
      context 'when they are obsolete combinations' do
        let(:taxon) { create :species, name_string: 'Oecodoma mexicana', genus: create(:genus, name_string: 'Oecodoma') }

        before do
          create :species, status: Status::OBSOLETE_COMBINATION, current_valid_taxon: taxon, protonym: taxon.protonym
        end

        specify { expect(policy.allowed?).to eq true }
      end

      context 'when they are synonyms' do
        let(:taxon) { create :species, name_string: 'Oecodoma mexicana', genus: create(:genus, name_string: 'Oecodoma') }

        before do
          create :species, status: Status::SYNONYM, current_valid_taxon: taxon
        end

        specify do
          expect(policy.allowed?).to eq false
          expect(policy.errors).to include "taxon has junior synonyms"
          expect(policy.errors).to include "taxon has unsupported 'What Links Here's"
        end
      end
    end
  end
end
