# frozen_string_literal: true

require 'rails_helper'

describe HistoryItem do
  it { is_expected.to be_versioned }

  describe 'relations' do
    it { is_expected.to belong_to(:protonym).required }
  end

  describe 'validations' do
    it { is_expected.to validate_inclusion_of(:type).in_array(described_class::TYPES) }

    it do
      is_expected.to validate_inclusion_of(:rank).
        in_array(Rank::AntCatSpecific::TYPE_SPECIFIC_HISTORY_ITEM_TYPES).allow_nil
    end
  end

  describe 'type-related validations' do
    context 'when `type` is `TAXT`' do
      subject { build_stubbed :history_item, :taxt }

      it do
        is_expected.to validate_presence_of :taxt
        is_expected.to validate_absence_of :subtype
        is_expected.to validate_absence_of :picked_value
        is_expected.to validate_absence_of :text_value

        is_expected.to validate_absence_of :reference
        is_expected.to validate_absence_of :pages
        is_expected.to validate_absence_of :object_protonym
        is_expected.to validate_absence_of :object_taxon
      end
    end

    context 'when `type` is `TYPE_SPECIMEN_DESIGNATION`' do
      subject { build_stubbed :history_item, :type_specimen_designation }

      it do
        is_expected.to validate_absence_of :taxt
        is_expected.to validate_presence_of :subtype
        is_expected.to validate_absence_of :picked_value
        is_expected.to validate_absence_of :text_value

        is_expected.to validate_presence_of :reference
        is_expected.to validate_presence_of :pages
        is_expected.to validate_absence_of :object_protonym
        is_expected.to validate_absence_of :object_taxon
      end

      it do
        is_expected.to validate_inclusion_of(:subtype).
          in_array(described_class::TYPE_SPECIMEN_DESIGNATION_SUBTYPES)
      end
    end

    context 'when `type` is `FORM_DESCRIPTIONS`' do
      subject { build_stubbed :history_item, :form_descriptions }

      it do
        is_expected.to validate_absence_of :taxt
        is_expected.to validate_absence_of :subtype
        is_expected.to validate_absence_of :picked_value
        is_expected.to validate_presence_of :text_value

        is_expected.to validate_presence_of :reference
        is_expected.to validate_presence_of :pages
        is_expected.to validate_absence_of :object_protonym
        is_expected.to validate_absence_of :object_taxon
      end
    end

    context 'when `type` is `COMBINATION_IN`' do
      subject { build_stubbed :history_item, :combination_in }

      it do
        is_expected.to validate_absence_of :taxt
        is_expected.to validate_absence_of :subtype
        is_expected.to validate_absence_of :picked_value
        is_expected.to validate_absence_of :text_value

        is_expected.to validate_presence_of :reference
        is_expected.to validate_presence_of :pages
        is_expected.to validate_absence_of :object_protonym
        is_expected.to validate_presence_of :object_taxon
      end
    end

    context 'when `type` is `JUNIOR_SYNONYM_OF`' do
      subject { build_stubbed :history_item, :junior_synonym_of }

      it do
        is_expected.to validate_absence_of :taxt
        is_expected.to validate_absence_of :subtype
        is_expected.to validate_absence_of :picked_value
        is_expected.to validate_absence_of :text_value

        is_expected.to validate_presence_of :reference
        is_expected.to validate_presence_of :pages
        is_expected.to validate_presence_of :object_protonym
        is_expected.to validate_absence_of :object_taxon
      end
    end

    context 'when `type` is `SENIOR_SYNONYM_OF`' do
      subject { build_stubbed :history_item, :senior_synonym_of }

      it do
        is_expected.to validate_absence_of :taxt
        is_expected.to validate_absence_of :subtype
        is_expected.to validate_absence_of :picked_value
        is_expected.to validate_absence_of :text_value

        is_expected.to validate_presence_of :reference
        is_expected.to validate_presence_of :pages
        is_expected.to validate_presence_of :object_protonym
        is_expected.to validate_absence_of :object_taxon
      end
    end

    context 'when `type` is `STATUS_AS_SPECIES`' do
      subject { build_stubbed :history_item, :status_as_species }

      it do
        is_expected.to validate_absence_of :taxt
        is_expected.to validate_absence_of :subtype
        is_expected.to validate_absence_of :picked_value
        is_expected.to validate_absence_of :text_value

        is_expected.to validate_presence_of :reference
        is_expected.to validate_presence_of :pages
        is_expected.to validate_absence_of :object_protonym
        is_expected.to validate_absence_of :object_taxon
      end
    end

    context 'when `type` is `SUBSPECIES_OF`' do
      subject { build_stubbed :history_item, :subspecies_of }

      it do
        is_expected.to validate_absence_of :taxt
        is_expected.to validate_absence_of :subtype
        is_expected.to validate_absence_of :picked_value
        is_expected.to validate_absence_of :text_value

        is_expected.to validate_presence_of :reference
        is_expected.to validate_presence_of :pages
        is_expected.to validate_absence_of :object_protonym
        is_expected.to validate_presence_of :object_taxon
      end
    end
  end

  describe 'callbacks' do
    it { is_expected.to strip_attributes(:taxt, :rank, :subtype, :picked_value, :text_value, :pages) }

    it_behaves_like "a taxt column with cleanup", :taxt do
      subject { build :history_item }
    end
  end

  describe 'TYPE_DEFINITIONS' do
    described_class::TYPE_DEFINITIONS.each do |type, definition|
      describe "type definition for #{type}" do
        it 'has all required attributes' do
          expect(definition[:type_label]).to be_present
          expect(definition[:ranks]).to be_present

          expect(definition[:group_order]).to be_present

          expect(definition[:group_template]).to be_present

          expect(definition[:validates_presence_of]).to be_present
        end
      end
    end
  end

  describe '#standard_format?' do
    context 'with `TAXT` item' do
      context 'with standard format' do
        let(:history_item) { create :history_item, taxt: 'Lectotype designation: {ref 1}: 23' }

        specify { expect(history_item.standard_format?).to eq true }
      end

      context 'with non-standard format' do
        let(:history_item) { create :history_item, taxt: 'Pizza designation: {ref 1}: 23' }

        specify { expect(history_item.standard_format?).to eq false }
      end
    end

    context 'with hybrid item' do
      let(:history_item) { create :history_item, :form_descriptions }

      specify { expect(history_item.standard_format?).to eq true }
    end
  end

  describe '#to_taxt' do
    context 'when `type` is `TYPE_SPECIMEN_DESIGNATION`' do
      context 'when `subtype` is `LECTOTYPE_DESIGNATION`' do
        let(:history_item) { create :history_item, :lectotype_designation }

        specify do
          expect(history_item.to_taxt).
            to eq "Lectotype designation: #{history_item.citation_taxt}."
        end
      end

      context 'when `subtype` is `NEOTYPE_DESIGNATION`' do
        let(:history_item) { create :history_item, :neotype_designation }

        specify do
          expect(history_item.to_taxt).
            to eq "Neotype designation: #{history_item.citation_taxt}."
        end
      end
    end

    context 'when `type` is `FORM_DESCRIPTIONS`' do
      let(:history_item) { create :history_item, :form_descriptions, text_value: 'q.' }

      specify do
        expect(history_item.to_taxt).to eq "#{history_item.citation_taxt} (q.)."
      end
    end

    context 'when `type` is `COMBINATION_IN`' do
      let(:history_item) { create :history_item, :combination_in }

      specify do
        expect(history_item.to_taxt).
          to eq "Combination in {tax #{history_item.object_taxon.id}}: #{history_item.citation_taxt}."
      end
    end

    context 'when `type` is `JUNIOR_SYNONYM_OF`' do
      let(:history_item) { create :history_item, :junior_synonym_of }

      specify do
        expect(history_item.to_taxt).
          to eq "Junior synonym of {prott #{history_item.object_protonym.id}}: #{history_item.citation_taxt}."
      end
    end

    context 'when `type` is `SENIOR_SYNONYM_OF`' do
      let(:history_item) { create :history_item, :senior_synonym_of }

      specify do
        expect(history_item.to_taxt).
          to eq "Senior synonym of {prott #{history_item.object_protonym.id}}: #{history_item.citation_taxt}."
      end
    end

    context 'when `type` is `STATUS_AS_SPECIES`' do
      let(:history_item) { create :history_item, :status_as_species }

      specify do
        expect(history_item.to_taxt).to eq "Status as species: #{history_item.citation_taxt}."
      end
    end

    context 'when `type` is `SUBSPECIES_OF`' do
      let(:history_item) { create :history_item, :subspecies_of }

      specify do
        expect(history_item.to_taxt).
          to eq "Subspecies of {tax #{history_item.object_taxon.id}}: #{history_item.citation_taxt}."
      end
    end
  end

  describe '#citation_taxt' do
    context 'with `TAXT` item' do
      let(:history_item) { create :history_item, taxt: 'Lectotype designation: {ref 1}: 23' }

      specify { expect { history_item.citation_taxt }.to raise_error('not supported') }
    end

    context 'with hybrid item' do
      context 'when item supports citations (`reference` + `pages`)' do
        let(:history_item) { create :history_item, :form_descriptions }

        specify do
          expect(history_item.citation_taxt).
            to eq "{ref #{history_item.reference.id}}: #{history_item.pages}"
        end
      end

      context 'when item does not support citations' do
        # For future item types.
      end
    end
  end

  describe '#ids_from_tax_or_taxac_tags' do
    context 'when taxt contains no tax or taxac tags' do
      let!(:history_item) { create :history_item, taxt: 'pizza festival' }

      specify { expect(history_item.ids_from_tax_or_taxac_tags).to eq [] }
    end

    context 'when taxt contains tax or taxac tags' do
      let(:taxon_1) { create :any_taxon }
      let(:taxon_2) { create :any_taxon }
      let!(:history_item) { create :history_item, taxt: "{tax #{taxon_1.id}}, {taxac #{taxon_2.id}}" }

      it 'returns IDs of taxa referenced in tax and taxac tags' do
        expect(history_item.ids_from_tax_or_taxac_tags).to match_array [taxon_1.id, taxon_2.id]
      end
    end
  end
end
