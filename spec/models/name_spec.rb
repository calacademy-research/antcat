# frozen_string_literal: true

require 'rails_helper'

describe Name do
  it { is_expected.to be_versioned }

  describe 'relations' do
    it { is_expected.to have_many(:protonyms).dependent(:restrict_with_error) }
    it { is_expected.to have_many(:taxa).dependent(:restrict_with_error) }
  end

  describe 'validations' do
    describe "#gender" do
      it { is_expected.to validate_inclusion_of(:gender).in_array(described_class::GENDERS).allow_nil }
    end

    describe '#name' do
      it { is_expected.to validate_presence_of :name }

      describe 'allowed characters' do
        subject(:name) { build_stubbed :family_name }

        let(:error_message) { "can only contain Latin letters, periods, dashes and parentheses" }

        it { is_expected.to_not allow_value('Capaö').for(:name).with_message(error_message) }
        it { is_expected.to_not allow_value('Capa1').for(:name).with_message(error_message) }
      end

      describe 'first letter in name' do
        let(:name) { build_stubbed :genus_name, name: 'lasius' }

        it 'must start with a capital letter' do
          expect(name.valid?).to eq false
          expect(name.errors[:name]).to eq ["must start with a capital letter"]
        end
      end
    end

    describe '#validate_number_of_name_parts' do
      let(:name) { build_stubbed :genus_name, name: 'Lasius niger' }

      specify do
        expect(name.valid?).to eq false
        expect(name.errors[:name]).
          to include "of type GenusName must contains 1 word parts (excluding subgenus part and connecting terms)"
      end
    end

    describe '#ensure_identified_name_type_matches' do
      context 'when name is identified as different to its type' do
        context 'when not a `SubtribeName`' do
          let(:name) { build_stubbed :family_name, name: 'Tribii' }

          specify do
            expect(name.valid?).to eq false
            expect(name.errors[:name]).
              to include "type (`FamilyName`) and identified name type (`TribeName`) must match. " \
                "Flag name as 'Non-conforming' to bypass this validation."
          end
        end

        context 'with `non_conforming` name' do
          let(:name) { build_stubbed :family_name, :non_conforming, name: 'Tribii' }

          it 'does not fail validations' do
            expect(name.valid?).to eq true

            expect { name.non_conforming = false }.to change { name.valid? }.from(true).to(false)
            expect(name.errors[:name]).
              to include "type (`FamilyName`) and identified name type (`TribeName`) must match. " \
                "Flag name as 'Non-conforming' to bypass this validation."
          end
        end

        context 'when a `SubtribeName`' do
          context 'with misidentified but valid -ina ending' do
            let(:name) { build_stubbed :subtribe_name, name: 'Subtribina' }

            it 'does not fail validations' do
              expect(name.valid?).to eq true
            end
          end

          context 'when name is not valid' do
            let(:name) { build_stubbed :subtribe_name, name: 'Subtribinus' }

            specify do
              expect(name.valid?).to eq false
              expect(name.errors[:name]).
                to include "type (`SubtribeName`) and identified name type (`GenusName`) must match. " \
                  "Flag name as 'Non-conforming' to bypass this validation."
            end
          end
        end
      end
    end
  end

  describe 'callbacks' do
    describe '#strip_attributes' do
      subject(:name) { SubspeciesName.new }

      it { is_expected.to strip_attributes(:name, :gender) }
    end

    describe '#set_epithet' do
      describe 'when name is not a `SubgenusName`' do
        let!(:name) { SubspeciesName.new(name: 'Lasius niger fusca') }

        it 'sets the epithet the last part of the name' do
          expect(name.epithet).to eq 'fusca'
        end
      end

      describe 'when name is a `SubgenusName`' do
        let!(:name) { SubgenusName.new(name: 'Lasius (Austrolasius)') }

        it 'sets the epithet the subgenus part of the name without parentheses' do
          expect(name.epithet).to eq 'Austrolasius'
        end
      end
    end

    describe '#set_cleaned_name' do
      let!(:name) { SubspeciesName.new(name: 'Lasius (Forelophilus) niger var. fusca') }

      specify { expect(name.cleaned_name).to eq 'Lasius niger fusca' }
    end

    describe "#set_taxon_name_cache" do
      let!(:eciton_name) { create :genus_name, name: 'Eciton' }

      context 'when name is assigned to a taxon' do
        let!(:taxon) { create :genus }

        it "sets the taxon's `name_cache`" do
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
