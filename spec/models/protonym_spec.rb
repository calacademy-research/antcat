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
    describe "#bioregion validations" do
      it do
        expect(build_stubbed(:protonym)).to validate_inclusion_of(:bioregion).
          in_array(described_class::BIOREGIONS).allow_nil
      end

      context 'when protonym is fossil' do
        let(:protonym) { build_stubbed :protonym, :fossil }

        it 'cannot have a `bioregion`' do
          expect { protonym.bioregion = described_class::NEARCTIC_REGION }.
            to change { protonym.valid? }.to(false)

          expect(protonym.errors.where(:bioregion).map(&:message)).
            to include("cannot be set for fossil protonyms")
        end
      end

      context 'when protonym is above species rank' do
        let(:protonym) { build_stubbed :protonym, :genus_group }

        it 'cannot have `bioregion`' do
          expect { protonym.bioregion = described_class::NEARCTIC_REGION }.
            to change { protonym.valid? }.to(false)

          expect(protonym.errors.where(:bioregion).map(&:message)).
            to include("can only be set for species-group names")
        end
      end
    end

    describe "#forms validations" do
      context 'when protonym is above species rank' do
        let(:protonym) { build_stubbed :protonym, :genus_group }

        it 'cannot have `forms`' do
          expect { protonym.forms = 'w.' }.
            to change { protonym.valid? }.to(false)

          expect(protonym.errors.where(:forms).map(&:message)).
            to include("can only be set for species-group names")
        end
      end
    end

    describe "#locality validations" do
      context 'when protonym is above species rank' do
        let(:protonym) { build_stubbed :protonym, :genus_group }

        it 'cannot have a `locality`' do
          expect { protonym.locality = 'Lund' }.
            to change { protonym.valid? }.to(false)

          expect(protonym.errors.where(:locality).map(&:message)).
            to include("can only be set for species-group names")
        end
      end
    end

    describe "#gender_agreement_type validations" do
      it do
        expect(build_stubbed(:protonym, :species_group)).
          to validate_inclusion_of(:gender_agreement_type).
          in_array(described_class::GENDER_AGREEMENT_TYPES).allow_nil
      end

      context 'when protonym is not a species-group name' do
        let(:protonym) { build_stubbed :protonym, :genus_group }

        it 'cannot have a `gender_agreement_type`' do
          expect { protonym.gender_agreement_type = described_class::PARTICIPLE }.
            to change { protonym.valid? }.to(false)

          expect(protonym.errors.where(:gender_agreement_type).map(&:message)).
            to include("can only be set for species-group names")
        end
      end
    end

    describe "gender epithet validations" do
      context 'when protonym is an adjective' do
        let(:protonym) { build_stubbed :protonym, :adjective_gender_agreement_type }

        it 'can have the three spellings' do
          protonym.assign_attributes(masculine_epithet: 'rufus', feminine_epithet: 'rufa', neuter_epithet: 'rufum')
          expect(protonym.valid?).to eq true
        end

        it 'requires each spelling to be a single lowercase epithet' do
          protonym.masculine_epithet = 'Rufus'
          expect(protonym.valid?).to eq false
          expect(protonym.errors.where(:masculine_epithet).map(&:message)).
            to include("must be a single lowercase epithet")
        end
      end

      context 'when protonym is a noun' do
        let(:protonym) { build_stubbed :protonym, :noun_in_apposition_gender_agreement_type }

        it 'cannot have spellings by gender' do
          expect { protonym.feminine_epithet = 'trocha' }.to change { protonym.valid? }.to(false)
          expect(protonym.errors.where(:feminine_epithet).map(&:message)).
            to include("can only be set when the gender agreement type is adjective or participle")
        end
      end

      context 'when protonym has no gender agreement type' do
        let(:protonym) { build_stubbed :protonym, :species_group }

        it 'cannot have spellings by gender' do
          expect { protonym.neuter_epithet = 'rufum' }.to change { protonym.valid? }.to(false)
        end
      end
    end

    describe "spelling basis validations" do
      context 'when protonym is a species-group name with a part of speech' do
        let(:protonym) { build_stubbed :protonym, :adjective_gender_agreement_type }

        it 'accepts the listed bases' do
          protonym.assign_attributes(part_of_speech_basis: 'decisive_usage', spelling_basis: 'gender_agreement')
          expect(protonym.valid?).to eq true
        end

        it 'rejects an unlisted basis' do
          protonym.spelling_basis = 'because Bolton said so'
          expect(protonym.valid?).to eq false
          expect(protonym.errors.where(:spelling_basis).map(&:message)).to include("is not included in the list")
        end
      end

      context 'when protonym has no part of speech' do
        let(:protonym) { build_stubbed :protonym, :species_group }

        it 'cannot have a part-of-speech basis' do
          expect { protonym.part_of_speech_basis = 'noun_by_default' }.to change { protonym.valid? }.to(false)
          expect(protonym.errors.where(:part_of_speech_basis).map(&:message)).to include("needs a gender agreement type")
        end

        it 'can still record the basis for the accepted spelling' do
          protonym.spelling_basis = 'original_spelling'
          expect(protonym.valid?).to eq true
        end
      end

      context 'when protonym is not a species-group name' do
        let(:protonym) { build_stubbed :protonym, :genus_group }

        it 'cannot have a spelling basis' do
          expect { protonym.spelling_basis = 'original_spelling' }.to change { protonym.valid? }.to(false)
        end
      end
    end

    describe "#interpretation_contested validations" do
      let(:protonym) { build_stubbed :protonym, :adjective_gender_agreement_type, interpretation_contested: true }

      it 'requires a public note' do
        expect(protonym.valid?).to eq false
        expect(protonym.errors.where(:interpretation_contested).map(&:message)).
          to include("needs a public note that gives the alternative interpretation and its evidence")
      end

      it 'does not count a hidden note' do
        protonym.notes_taxt = "{hiddennote alternative reading: a noun phrase}"
        expect(protonym.valid?).to eq false
      end

      it 'is valid with a public note' do
        protonym.notes_taxt = "Spelling: an alternative reading is a noun phrase, which keeps the original spelling."
        expect(protonym.valid?).to eq true
      end
    end

    describe "#ichnotaxon validations" do
      context 'when protonym is not fossil' do
        let(:protonym) { build_stubbed :protonym }

        it 'cannot be a `ichnotaxon`' do
          expect { protonym.ichnotaxon = true }.to change { protonym.valid? }.to(false)

          expect(protonym.errors.where(:ichnotaxon).map(&:message)).
            to include("can only be set for fossil protonyms")
        end
      end
    end
  end

  describe 'callbacks' do
    it { is_expected.to strip_attributes(:locality, :bioregion, :forms, :gender_agreement_type, :notes_taxt) }
    it { is_expected.to strip_attributes(:masculine_epithet, :feminine_epithet, :neuter_epithet) }
    it { is_expected.to strip_attributes(:part_of_speech_basis, :spelling_basis) }
    it { is_expected.to strip_attributes(:etymology_taxt) }
    it { is_expected.to strip_attributes(:primary_type_information_taxt, :secondary_type_information_taxt, :type_notes_taxt) }

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

  describe "#plain_text_author_citation" do
    let!(:reference) { create :any_reference, author_string: 'Bolton', year: 2005, year_suffix: 'b' }
    let!(:protonym) { create :protonym, authorship: create(:citation, reference: reference) }

    it "keeps an older author name as it is" do
      reference.author_names.first.update_columns(name: 'O&Brien')
      expect(protonym.reload.plain_text_author_citation).to eq 'O&Brien, 2005'
      expect(protonym.author_citation).to eq 'O&amp;Brien, 2005'
    end
  end

  describe "#gender_epithets and #epithet_for_gender" do
    let(:protonym) do
      build_stubbed :protonym, :adjective_gender_agreement_type,
        masculine_epithet: 'crassispinus', feminine_epithet: 'crassispina', neuter_epithet: 'crassispinum'
    end

    specify do
      expect(protonym.gender_epithets).to eq(
        'masculine' => 'crassispinus', 'feminine' => 'crassispina', 'neuter' => 'crassispinum'
      )
    end

    specify { expect(protonym.epithet_for_gender('feminine')).to eq 'crassispina' }
    specify { expect(protonym.epithet_for_gender(nil)).to eq nil }

    context 'when no spellings are recorded' do
      let(:protonym) { build_stubbed :protonym, :adjective_gender_agreement_type }

      specify { expect(protonym.gender_epithets).to eq nil }
    end
  end

  describe "#predicted_gender_epithets" do
    let(:protonym) do
      build_stubbed :protonym, :adjective_gender_agreement_type, name: SpeciesName.new(name: 'Formica crassispina')
    end

    specify do
      expect(protonym.predicted_gender_epithets).to eq(
        'masculine' => 'crassispinus', 'feminine' => 'crassispina', 'neuter' => 'crassispinum'
      )
    end
  end

  describe "changeable / unchangeable names" do
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
