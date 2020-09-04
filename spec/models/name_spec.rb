# frozen_string_literal: true

require 'rails_helper'

describe Name do
  it { is_expected.to be_versioned }

  describe 'relations' do
    it { is_expected.to have_many(:protonyms).dependent(:restrict_with_error) }
    it { is_expected.to have_many(:taxa).dependent(:restrict_with_error) }
  end

  describe 'validations' do
    describe '#name' do
      it { is_expected.to validate_presence_of :name }
    end

    describe '#validate_number_of_name_parts' do
      let(:name) { build_stubbed :genus_name, name: 'Lasius niger' }

      specify do
        expect(name.valid?).to eq false
        expect(name.errors[:name]).
          to eq ["of type GenusName must contains 1 word parts (excluding subgenus part and rank abbreviations)"]
      end
    end

    describe '#ensure_starts_with_upper_case_letter' do
      let(:name) { build_stubbed :genus_name, name: 'lasius' }

      specify do
        expect(name.valid?).to eq false
        expect(name.errors[:name]).to eq ["must start with a capital letter"]
      end
    end
  end

  describe 'callbacks' do
    describe '#strip_attributes' do
      subject(:name) { SubspeciesName.new }

      it { is_expected.to strip_attributes(:name, :epithet, :gender) }
    end

    describe '#set_epithet' do
      let!(:name) { SubspeciesName.new(name: 'Lasius niger fusca') }

      before do
        name.attributes = { epithet: 'pizza' }
      end

      specify { expect { name.save }.to change { name.epithet }.from('pizza').to('fusca') }
    end

    describe '#set_cleaned_name' do
      let!(:name) { SubspeciesName.new(name: 'Lasius (Forelophilus) niger var. fusca') }

      specify { expect { name.save }.to change { name.cleaned_name }.to('Lasius niger fusca') }
    end

    describe "#set_taxon_name_cache" do
      let!(:eciton_name) { create :genus_name, name: 'Eciton' }

      context 'when name is assigned to a taxon' do
        let!(:taxon) { create :genus }

        it "sets the taxons's `name_cache`" do
          expect { taxon.update!(name: eciton_name) }.
            to change { taxon.reload.name_cache }.to('Eciton')
        end
      end

      context 'when the contents of the name change' do
        let!(:taxon) { create :genus, name: eciton_name }

        it "updates the taxon's `name_cache`" do
          expect { eciton_name.update!(name: 'Atta') }.
            to change { taxon.reload.name_cache }.to('Atta')
        end
      end
    end
  end

  describe "#name_with_fossil_html" do
    it "formats the fossil symbol" do
      expect(SpeciesName.new(name: 'Atta major').name_with_fossil_html(false)).to eq '<i>Atta major</i>'
      expect(SpeciesName.new(name: 'Atta major').name_with_fossil_html(true)).to eq '<i>†</i><i>Atta major</i>'
    end
  end
end
