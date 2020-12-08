# frozen_string_literal: true

require 'rails_helper'

describe Protonym do
  it { is_expected.to be_versioned }

  describe 'relations' do
    it { is_expected.to belong_to(:name).dependent(:destroy) }
    it { is_expected.to belong_to(:name).required }
    it { is_expected.to belong_to(:authorship).dependent(:destroy) }
    it { is_expected.to belong_to(:authorship).required }
    it { is_expected.to have_many(:history_items).dependent(:restrict_with_error) }
    it { is_expected.to have_many(:taxa).class_name('Taxon').dependent(:restrict_with_error) }
    it { is_expected.to have_one(:terminal_taxon).class_name('Taxon') }
  end

  describe 'validations' do
    describe "#biogeographic_region" do
      it do
        expect(build_stubbed(:protonym)).to validate_inclusion_of(:biogeographic_region).
          in_array(described_class::BIOGEOGRAPHIC_REGIONS).allow_nil
      end

      context 'when protonym is fossil' do
        let(:protonym) { build_stubbed :protonym, :fossil }

        it 'cannot have a `biogeographic_region`' do
          expect { protonym.biogeographic_region = described_class::NEARCTIC_REGION }.
            to change { protonym.valid? }.to(false)

          expect(protonym.errors.messages).to include(biogeographic_region: ["cannot be set for fossil protonyms"])
        end
      end
    end

    describe "#gender_agreement_type" do
      it do
        expect(build_stubbed(:protonym, :species_group_name)).
          to validate_inclusion_of(:gender_agreement_type).
          in_array(described_class::GENDER_AGREEMENT_TYPES).allow_nil
      end

      context 'when protonym is not a species-group name' do
        let(:protonym) { build_stubbed :protonym, :genus_group_name }

        it 'cannot have a `gender_agreement_type`' do
          expect { protonym.gender_agreement_type = described_class::PARTICIPLE }.
            to change { protonym.valid? }.to(false)

          expect(protonym.errors.messages).to include(gender_agreement_type: ["can only be set for species-group names"])
        end
      end
    end

    describe "#ichnotaxon" do
      context 'when protonym is not fossil' do
        let(:protonym) { build_stubbed :protonym }

        it 'cannot be a `ichnotaxon`' do
          expect { protonym.ichnotaxon = true }.to change { protonym.valid? }.to(false)
          expect(protonym.errors.messages).to include(ichnotaxon: ["can only be set for fossil protonyms"])
        end
      end
    end
  end

  describe 'callbacks' do
    it { is_expected.to strip_attributes(:locality, :biogeographic_region, :forms, :gender_agreement_type, :notes_taxt) }
    it { is_expected.to strip_attributes(:etymology_taxt, :primary_type_information_taxt, :secondary_type_information_taxt, :type_notes_taxt) }

    it_behaves_like "a taxt column with cleanup", :etymology_taxt do
      subject { build :protonym }
    end

    it_behaves_like "a taxt column with cleanup", :primary_type_information_taxt do
      subject { build :protonym }
    end

    it_behaves_like "a taxt column with cleanup", :secondary_type_information_taxt do
      subject { build :protonym }
    end

    it_behaves_like "a taxt column with cleanup", :type_notes_taxt do
      subject { build :protonym }
    end

    it_behaves_like "a taxt column with cleanup", :notes_taxt do
      subject { build :protonym }
    end
  end

  describe "#author_citation" do
    let!(:reference) { create :any_reference, author_string: 'Bolton', year: 2005, year_suffix: 'b' }
    let!(:protonym) { create :protonym, authorship: create(:citation, reference: reference) }

    it 'does not include year suffixes' do
      expect(protonym.author_citation).to eq 'Bolton, 2005'
    end
  end

  describe "changable / unchangeable names" do
    context 'when `gender_agreement_type` is `ADJECTIVE`' do
      let(:protonym) { build_stubbed :protonym, :adjective_gender_agreement_type }

      specify { expect(protonym.changeable_name?).to eq true }
      specify { expect(protonym.unchangeable_name?).to eq false }
    end

    context 'when `gender_agreement_type` is `NOUN_IN_APPOSITION`' do
      let(:protonym) { build_stubbed :protonym, :noun_in_apposition_gender_agreement_type }

      specify { expect(protonym.changeable_name?).to eq false }
      specify { expect(protonym.unchangeable_name?).to eq true }
    end

    context 'when `gender_agreement_type` is `NOUN_IN_GENITIVE_CASE`' do
      let(:protonym) { build_stubbed :protonym, :noun_in_genitive_case_gender_agreement_type }

      specify { expect(protonym.changeable_name?).to eq false }
      specify { expect(protonym.unchangeable_name?).to eq true }
    end

    context 'when `gender_agreement_type` is `PARTICIPLE`' do
      let(:protonym) { build_stubbed :protonym, :participle_gender_agreement_type }

      specify { expect(protonym.changeable_name?).to eq true }
      specify { expect(protonym.unchangeable_name?).to eq false }
    end

    context 'when `gender_agreement_type` is blank' do
      let(:protonym) { build_stubbed :protonym, :blank_gender_agreement_type }

      specify { expect(protonym.changeable_name?).to eq false }
      specify { expect(protonym.unchangeable_name?).to eq false }
    end
  end
end
