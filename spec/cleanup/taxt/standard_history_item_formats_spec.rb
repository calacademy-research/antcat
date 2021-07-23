# frozen_string_literal: true

require 'rails_helper'

describe Taxt::StandardHistoryItemFormats do
  subject(:service) { described_class.new(taxt) }

  describe 'parsing pagination' do
    let(:taxt) { "[Also described as new by #{Taxt.ref(2)}: #{pagination}.]" }

    context "with unparsable pagination" do
      let(:pagination) { "123abc" }

      specify { expect(service.standard?).to eq false }
    end

    context "with single page" do
      let(:pagination) { "3" }

      specify { expect(service.standard?).to eq true }
    end

    context "with page with parens" do
      let(:pagination) { "3 (in key)" }

      specify { expect(service.standard?).to eq true }
    end

    context "with Roman page" do
      let(:pagination) { "xii" }

      specify { expect(service.standard?).to eq true }
    end

    context "with page + page with parens" do
      let(:pagination) { "1, 3 (in key)" }

      specify { expect(service.standard?).to eq true }
    end

    context "with page + page with parens + Roman page" do
      let(:pagination) { "1, 3 (in key), ci" }

      specify { expect(service.standard?).to eq true }
    end

    context "with page + page with parens + Roman page with parent" do
      let(:pagination) { "1, 3 (in key), ci (footnote)" }

      specify { expect(service.standard?).to eq true }
    end
  end

  describe 'parsing grouped citations' do
    let(:taxt) { "Material referred to #{Taxt.tax(1)} by #{citation}." }

    context "with unparsable grouped citations" do
      let(:citation) { "#{Taxt.ref(125536)}: 135; #{Taxt.ref(125536)}:" }

      specify { expect(service.standard?).to eq false }
    end

    context "with one citation" do
      let(:citation) { "#{Taxt.ref(125536)}: 135" }

      specify { expect(service.standard?).to eq true }
    end

    context "with two citations" do
      let(:citation) { "#{Taxt.ref(125536)}: 12; #{Taxt.ref(234567)}: 13" }

      specify { expect(service.standard?).to eq true }
    end
  end

  describe '#standard?' do
    context 'with blank item' do
      let(:taxt) { '' }

      specify do
        expect(service.standard?).to eq false
        expect(service.identified_type).to eq History::Definitions::TAXT
      end
    end

    context 'with nil item' do
      let(:taxt) { nil }

      specify do
        expect(service.standard?).to eq false
        expect(service.identified_type).to eq History::Definitions::TAXT
      end
    end

    context 'with non-standard item' do
      let(:taxt) { 'pizza' }

      specify do
        expect(service.standard?).to eq false
        expect(service.identified_type).to eq History::Definitions::TAXT
      end
    end

    context "with form descriptions item" do
      context 'with known forms' do
        let(:taxt) { "#{Taxt.ref(1)}: 2 (w.q.m.)." }

        specify do
          expect(service.standard?).to eq true
          expect(service.identified_type).to eq History::Definitions::FORM_DESCRIPTIONS
        end
      end

      context 'with unknown forms' do
        let(:taxt) { "#{Taxt.ref(1)}: 2 (z.q.m.)." }

        specify do
          expect(service.standard?).to eq false
          expect(service.identified_type).to eq History::Definitions::TAXT
        end
      end
    end

    context "with 'Lectotype designation' item" do
      let(:taxt) { "Lectotype designation: #{Taxt.ref(1)}: 23" }

      specify do
        expect(service.standard?).to eq true
        expect(service.identified_type).to eq History::Definitions::TYPE_SPECIMEN_DESIGNATION
      end
    end

    context "with 'Neotype designation' item" do
      let(:taxt) { "Neotype designation: #{Taxt.ref(1)}: 23" }

      specify do
        expect(service.standard?).to eq true
        expect(service.identified_type).to eq History::Definitions::TYPE_SPECIMEN_DESIGNATION
      end
    end

    context "with 'Combination in' item" do
      let(:taxt) { "Combination in #{Taxt.tax(1)}: #{Taxt.ref(2)}: 3." }

      specify do
        expect(service.standard?).to eq true
        expect(service.identified_type).to eq History::Definitions::COMBINATION_IN
      end
    end

    context "with 'Junior synonym of' item" do
      let(:taxt) { "Junior synonym of #{Taxt.prott(1)}: #{Taxt.ref(2)}: 3." }

      specify do
        expect(service.standard?).to eq true
        expect(service.identified_type).to eq History::Definitions::JUNIOR_SYNONYM_OF
      end
    end

    context "with 'Senior synonym of' item" do
      let(:taxt) { "Senior synonym of #{Taxt.prott(1)}: #{Taxt.ref(2)}: 3." }

      specify do
        expect(service.standard?).to eq true
        expect(service.identified_type).to eq History::Definitions::SENIOR_SYNONYM_OF
      end
    end

    context "with 'Status as species' item" do
      let(:taxt) { "Status as species: #{Taxt.ref(1)}: 23" }

      specify do
        expect(service.standard?).to eq true
        expect(service.identified_type).to eq History::Definitions::STATUS_AS_SPECIES
      end
    end

    context "with 'Subspecies of' item" do
      let(:taxt) { "Subspecies of #{Taxt.tax(1)}: #{Taxt.ref(2)}: 3." }

      specify do
        expect(service.standard?).to eq true
        expect(service.identified_type).to eq History::Definitions::SUBSPECIES_OF
      end
    end

    context "with 'Replacement name:' item" do
      let(:taxt) { "Replacement name: #{Taxt.prottac(1)}." }

      specify do
        expect(service.standard?).to eq true
        expect(service.identified_type).to eq History::Definitions::HOMONYM_REPLACED_BY
      end
    end

    context "with 'Replacement name:' item with source" do
      let(:taxt) { "Replacement name: #{Taxt.prottac(1)} (#{Taxt.ref(2)}: 3)." }

      specify do
        expect(service.standard?).to eq true
        expect(service.identified_type).to eq History::Definitions::HOMONYM_REPLACED_BY
      end
    end

    context "with 'Replacement name for' item" do
      let(:taxt) { "Replacement name for #{Taxt.taxac(1)}." }

      specify do
        expect(service.standard?).to eq true
        expect(service.identified_type).to eq History::Definitions::REPLACEMENT_NAME_FOR
      end
    end

    context "with 'Unnecessary replacement name for' item" do
      let(:taxt) { "Unnecessary replacement name for #{Taxt.taxac(1)}." }

      specify do
        expect(service.standard?).to eq true
        expect(service.identified_type).to eq described_class::UNNECESSARY_REPLACEMENT_NAME_FOR
      end
    end

    # Candidates.

    context "with genus- or family-group 'Junior synonym of' item" do
      let(:taxt) { "#{Taxt.taxac(1)} as junior synonym of #{Taxt.prott(1)}: #{Taxt.ref(2)}: 3." }

      specify do
        expect(service.identified_type).to eq described_class::JUNIOR_SYNONYM_OF__GENUS_OR_FAMILY_GROUP
      end
    end

    context "with genus- or family-group 'Senior synonym of' item" do
      let(:taxt) { "#{Taxt.taxac(1)} as senior synonym of #{Taxt.prott(1)}: #{Taxt.ref(2)}: 3." }

      specify do
        expect(service.identified_type).to eq described_class::SENIOR_SYNONYM_OF__GENUS_OR_FAMILY_GROUP
      end
    end

    context "with 'Unidentifiable taxon' item" do
      let(:taxt) { "Unidentifiable taxon: #{Taxt.ref(2)}: 3." }

      specify do
        expect(service.identified_type).to eq described_class::UNIDENTIFIABLE_TAXON
      end
    end

    context "with 'as subfamily of' item" do
      let(:taxt) { "#{Taxt.tax(1)} as subfamily of #{Taxt.tax(1)}: #{Taxt.ref(2)}: 3." }

      specify do
        expect(service.identified_type).to eq described_class::AS_SUBFAMILY_OF
      end
    end

    context "with 'as tribe of' item" do
      let(:taxt) { "#{Taxt.tax(1)} as tribe of #{Taxt.tax(1)}: #{Taxt.ref(2)}: 3." }

      specify do
        expect(service.identified_type).to eq described_class::AS_TRIBE_OF
      end
    end

    context "with 'as subtribe of' item" do
      let(:taxt) { "#{Taxt.tax(1)} as subtribe of #{Taxt.tax(1)}: #{Taxt.ref(2)}: 3." }

      specify do
        expect(service.identified_type).to eq described_class::AS_SUBTRIBE_OF
      end
    end

    context "with 'as genus' item" do
      let(:taxt) { "#{Taxt.tax(1)} as genus: #{Taxt.ref(2)}: 3." }

      specify do
        expect(service.identified_type).to eq described_class::AS_GENUS
      end
    end

    context "with 'as subgenus of' item" do
      let(:taxt) { "#{Taxt.tax(1)} as subgenus of #{Taxt.tax(1)}: #{Taxt.ref(2)}: 3." }

      specify do
        expect(service.identified_type).to eq described_class::AS_SUBGENUS_OF
      end
    end

    context "with 'x in x' item" do
      let(:taxt) { "#{Taxt.tax(1)} in #{Taxt.tax(1)}: #{Taxt.ref(2)}: 3." }

      specify do
        expect(service.identified_type).to eq described_class::X_IN_X
      end
    end

    context "with 'x in unmissing' item" do
      let(:taxt) { "#{Taxt.tax(1)} in {#{Taxt::UNMISSING_TAG} <i>a</i>}: #{Taxt.ref(2)}: 3." }

      specify do
        expect(service.identified_type).to eq described_class::X_IN_UNMISSING
      end
    end

    context "with 'x in x, x' item" do
      let(:taxt) { "#{Taxt.tax(1)} in #{Taxt.tax(1)}, #{Taxt.tax(1)}: #{Taxt.ref(2)}: 3." }

      specify do
        expect(service.identified_type).to eq described_class::X_IN_X_X
      end
    end

    context "with 'x incertae sedis in x' item" do
      let(:taxt) { "#{Taxt.tax(1)} <i>incertae sedis</i> in #{Taxt.tax(1)}: #{Taxt.ref(2)}: 3." }

      specify do
        expect(service.identified_type).to eq described_class::X_INCERTAE_SEDIS_IN_X
      end
    end

    context "with 'Unnecessary ([not first]) replacement name for' item" do
      let(:taxt) { "Unnecessary (second) replacement name for #{Taxt.taxac(1)}." }

      specify do
        expect(service.identified_type).to eq described_class::UNNECESSARY_REPLACEMENT_NAME_FOR__AFTER_FIRST
      end
    end

    context "with 'Material referred to' item with source" do
      let(:taxt) do
        "Material referred to #{Taxt.tax(1)} by #{Taxt.ref(125536)}: 135"
      end

      specify do
        expect(service.identified_type).to eq described_class::MATERIAL_REFERRED_TO_BY
      end
    end

    context "with 'Unavailable name' + 'material referred to' item with source" do
      let(:taxt) do
        "Unavailable name; material referred to #{Taxt.tax(1)} by #{Taxt.ref(125536)}: 135"
      end

      specify do
        expect(service.identified_type).to eq described_class::UNAVAILABLE_NAME_AND_MATERIAL_REFERRED_TO_BY
      end
    end

    context "with 'As unavailable (infrasubspecific) name' item" do
      let(:taxt) do
        "As unavailable (infrasubspecific) name: #{Taxt.ref(2)}: 3."
      end

      specify do
        expect(service.identified_type).to eq described_class::AS_UNAVAILABLE_INFRASUBSPECIFIC_NAME
      end
    end

    context "with 'Declared as unavailable (infrasubspecific) name' item" do
      let(:taxt) do
        "Declared as unavailable (infrasubspecific) name: #{Taxt.ref(2)}: 3."
      end

      specify do
        expect(service.identified_type).to eq described_class::DECLARED_AS_UNAVAILABLE_INFRASUBSPECIFIC_NAME
      end
    end

    context "with 'First available use of unavailable (infrasubspecific) name' item" do
      let(:taxt) { "[First available use of #{Taxt.taxac(1)}; unavailable (infrasubspecific) name.]" }

      specify do
        expect(service.identified_type).to eq described_class::FIRST_AVAILABLE_USE_OF_UNAVAILABLE_INFRASUBSPECIFIC_NAME
      end
    end

    context "with 'First available use of unavailable (infrasubspecific) name' item with source" do
      let(:taxt) do
        "[First available use of #{Taxt.taxac(1)}; unavailable (infrasubspecific) name (#{Taxt.ref(2)}: 3).]"
      end

      specify do
        expect(service.identified_type).to eq described_class::FIRST_AVAILABLE_USE_OF_UNAVAILABLE_INFRASUBSPECIFIC_NAME__WITH_SOURCE
      end
    end

    context "with genus-group 'Also described as new by' item" do
      let(:taxt) { "[#{Taxt.taxac(1)} also described as new by #{Taxt.ref(2)}: 3.]" }

      specify do
        expect(service.identified_type).to eq described_class::ALSO_DESCRIBED_AS_NEW_BY__GENUS_GROUP
      end
    end

    context "with species-group 'Also described as new by' item" do
      let(:taxt) { "[Also described as new by #{Taxt.ref(2)}: 3.]" }

      specify do
        expect(service.identified_type).to eq described_class::ALSO_DESCRIBED_AS_NEW_BY__SPECIES_GROUP
      end
    end

    context "with 'Misspelled as by' item" do
      let(:taxt) { "[Misspelled as {#{Taxt::MISSPELLING_TAG} <i>rhomboidea</i>} by #{Taxt.ref(2)}: 3.]" }

      specify do
        expect(service.identified_type).to eq described_class::MISSPELLED_AS_BY
      end
    end
  end

  describe '#deprecated?' do
    context "with 'See also' item" do
      let(:taxt) { "See also: #{Taxt.ref(2)}: 3." }

      specify do
        expect(service.deprecated?).to eq true
        expect(service.identified_type).to eq described_class::SEE_ALSO
      end
    end

    context "with 'Revived status as species' item" do
      let(:taxt) { "Revived status as species: #{Taxt.ref(2)}: 3." }

      specify do
        expect(service.deprecated?).to eq true
        expect(service.identified_type).to eq described_class::REVIVED_STATUS_AS_SPECIES
      end
    end

    context "with 'Raised to species' item" do
      let(:taxt) { "Raised to species: #{Taxt.ref(2)}: 3." }

      specify do
        expect(service.deprecated?).to eq true
        expect(service.identified_type).to eq described_class::RAISED_TO_SPECIES
      end
    end
  end
end
