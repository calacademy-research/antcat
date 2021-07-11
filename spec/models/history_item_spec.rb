# frozen_string_literal: true

require 'rails_helper'

describe HistoryItem, :relational_hi do
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

    describe '#object_protonym_id' do
      let(:history_item) { build_stubbed :history_item, :junior_synonym_of }

      it 'cannot refer to its own protonym in `object_protonym_id`' do
        expect { history_item.object_protonym = history_item.protonym }.to change { history_item.valid? }.to(false)

        expect(history_item.errors.where(:object_protonym).map(&:message)).
          to include("cannot be the same as the history item's protonym")
      end
    end

    describe '#pages' do
      subject(:history_item) { build_stubbed :history_item, :junior_synonym_of }

      let(:format_error_message) { "cannot contain: ; < > { }" }

      it { is_expected.to validate_length_of(:pages).is_at_most(described_class::PAGES_MAX_LENGTH) }

      it { is_expected.to allow_value('1').for :pages }
      it { is_expected.to allow_value('1, 2-3').for :pages }
      it { is_expected.to allow_value('1 (in text)').for :pages }

      it { is_expected.not_to allow_value('1; 2').for(:pages).with_message(format_error_message) }
      it { is_expected.not_to allow_value("{#{Taxt::REF_TAG} 1}").for(:pages).with_message(format_error_message) }
      it { is_expected.not_to allow_value('<').for(:pages).with_message(format_error_message) }
    end

    describe '#validate_optional_reference_and_pages' do
      context 'with relational history item' do
        context 'when `reference` and `pages` are optional for item type' do
          let(:history_item) { build_stubbed :history_item, :unavailable_name }

          it 'must have both `reference` and `pages`, or neither' do
            expect { history_item.pages = '5' }.to change { history_item.valid? }.to(false)

            expect(history_item.errors.where(:base).map(&:message)).
              to include("Reference and pages can't be blank if one of them is not")
          end
        end
      end
    end

    describe '#text_value' do
      subject(:history_item) { build_stubbed :history_item, :form_descriptions }

      let(:format_error_message) { "cannot contain: ; < > { }" }

      it { is_expected.to validate_length_of(:text_value).is_at_most(described_class::TEXT_VALUE_MAX_LENGTH) }

      it { is_expected.to allow_value('w.').for :text_value }
      it { is_expected.to allow_value('abc q, w.').for :text_value }
      it { is_expected.to allow_value('w. (abc)').for :text_value }

      it { is_expected.not_to allow_value('w.; q.').for(:text_value).with_message(format_error_message) }
      it { is_expected.not_to allow_value("{#{Taxt::REF_TAG} 1}").for(:text_value).with_message(format_error_message) }
      it { is_expected.not_to allow_value('<').for(:text_value).with_message(format_error_message) }
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
          in_array(History::Definitions::TYPE_SPECIMEN_DESIGNATION_SUBTYPES)
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
        is_expected.to validate_presence_of :object_protonym
        is_expected.to validate_absence_of :object_taxon
      end
    end

    context 'when `type` is `HOMONYM_REPLACED_BY`' do
      subject { build_stubbed :history_item, :homonym_replaced_by }

      it do
        is_expected.to validate_absence_of :taxt
        is_expected.to validate_absence_of :subtype
        is_expected.to validate_absence_of :picked_value
        is_expected.to validate_absence_of :text_value

        is_expected.to validate_presence_of :object_protonym
        is_expected.to validate_absence_of :object_taxon
      end
    end

    context 'when `type` is `REPLACEMENT_NAME_FOR`' do
      subject { build_stubbed :history_item, :replacement_name_for }

      it do
        is_expected.to validate_absence_of :taxt
        is_expected.to validate_absence_of :subtype
        is_expected.to validate_absence_of :picked_value
        is_expected.to validate_absence_of :text_value

        is_expected.to validate_presence_of :object_protonym
        is_expected.to validate_absence_of :object_taxon
      end
    end

    context 'when `type` is `UNAVAILABLE_NAME`' do
      subject { build_stubbed :history_item, :unavailable_name }

      it do
        is_expected.to validate_absence_of :taxt
        is_expected.to validate_absence_of :subtype
        is_expected.to validate_absence_of :picked_value
        is_expected.to validate_absence_of :text_value

        is_expected.to validate_absence_of :object_protonym
        is_expected.to validate_absence_of :object_taxon
      end
    end
  end

  describe 'callbacks' do
    it { is_expected.to strip_attributes(:taxt, :rank, :subtype, :picked_value, :text_value, :pages) }

    it_behaves_like "a taxt column with cleanup", :taxt do
      subject { build :history_item }
    end
  end

  describe '#standard_format?' do
    context 'with `TAXT` item' do
      context 'with standard format' do
        let(:history_item) { create :history_item, :taxt, taxt: "Lectotype designation: {#{Taxt::REF_TAG} 1}: 23" }

        specify { expect(history_item.standard_format?).to eq true }
      end

      context 'with non-standard format' do
        let(:history_item) { create :history_item, :taxt, taxt: "Pizza designation: {#{Taxt::REF_TAG} 1}: 23" }

        specify { expect(history_item.standard_format?).to eq false }
      end
    end

    context 'with relational item' do
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
          to eq "Combination in {#{Taxt::TAX_TAG} #{history_item.object_taxon.id}}: #{history_item.citation_taxt}."
      end
    end

    context 'when `type` is `JUNIOR_SYNONYM_OF`' do
      context 'without `force_author_citation`' do
        let(:history_item) { create :history_item, :junior_synonym_of }

        specify do
          expect(history_item.to_taxt).
            to eq "Junior synonym of {#{Taxt::PROTT_TAG} #{history_item.object_protonym.id}}: #{history_item.citation_taxt}."
        end
      end

      context 'with `force_author_citation`' do
        let(:history_item) { create :history_item, :junior_synonym_of, :force_author_citation }

        specify do
          expect(history_item.to_taxt).
            to eq "Junior synonym of {#{Taxt::PROTTAC_TAG} #{history_item.object_protonym.id}}: #{history_item.citation_taxt}."
        end
      end

      context 'with `object` template' do
        let(:history_item) { create :history_item, :junior_synonym_of }

        specify do
          expect(history_item.to_taxt(:object)).
            to eq "Senior synonym of {#{Taxt::PROTT_TAG} #{history_item.protonym.id}}: #{history_item.citation_taxt}."
        end
      end
    end

    context 'when `type` is `SENIOR_SYNONYM_OF`' do
      context 'without `force_author_citation`' do
        let(:history_item) { create :history_item, :senior_synonym_of }

        specify do
          expect(history_item.to_taxt).
            to eq "Senior synonym of {#{Taxt::PROTT_TAG} #{history_item.object_protonym.id}}: #{history_item.citation_taxt}."
        end
      end

      context 'with `force_author_citation`' do
        let(:history_item) { create :history_item, :senior_synonym_of, :force_author_citation }

        specify do
          expect(history_item.to_taxt).
            to eq "Senior synonym of {#{Taxt::PROTTAC_TAG} #{history_item.object_protonym.id}}: #{history_item.citation_taxt}."
        end
      end
    end

    context 'when `type` is `STATUS_AS_SPECIES`' do
      let(:history_item) { create :history_item, :status_as_species }

      specify do
        expect(history_item.to_taxt).to eq "Status as species: #{history_item.citation_taxt}."
      end
    end

    context 'when `type` is `SUBSPECIES_OF`' do
      context 'without `force_author_citation`' do
        let(:history_item) { create :history_item, :subspecies_of }

        specify do
          expect(history_item.to_taxt).
            to eq "Subspecies of {#{Taxt::PROTT_TAG} #{history_item.object_protonym.id}}: #{history_item.citation_taxt}."
        end
      end

      context 'with `force_author_citation`' do
        let(:history_item) { create :history_item, :subspecies_of, :force_author_citation }

        specify do
          expect(history_item.to_taxt).
            to eq "Subspecies of {#{Taxt::PROTTAC_TAG} #{history_item.object_protonym.id}}: #{history_item.citation_taxt}."
        end
      end
    end

    context 'when `type` is `HOMONYM_REPLACED_BY`' do
      context 'without reference' do
        let(:history_item) { create :history_item, :homonym_replaced_by }

        specify do
          expect(history_item.to_taxt).
            to eq "Replacement name: {#{Taxt::PROTTAC_TAG} #{history_item.object_protonym.id}}."
        end
      end

      context 'with reference' do
        let(:history_item) { create :history_item, :homonym_replaced_by, :with_reference }

        specify do
          expect(history_item.to_taxt).
            to eq "Replacement name: {#{Taxt::PROTTAC_TAG} #{history_item.object_protonym.id}} (#{history_item.citation_taxt})."
        end
      end
    end

    context 'when `type` is `REPLACEMENT_NAME_FOR`' do
      context 'without reference' do
        let(:history_item) { create :history_item, :replacement_name_for }

        specify do
          expect(history_item.to_taxt).
            to eq "Replacement name for {#{Taxt::PROTTAC_TAG} #{history_item.object_protonym.id}}."
        end
      end

      context 'with reference' do
        let(:history_item) { create :history_item, :replacement_name_for, :with_reference }

        specify do
          expect(history_item.to_taxt).
            to eq "Replacement name for {#{Taxt::PROTTAC_TAG} #{history_item.object_protonym.id}} (#{history_item.citation_taxt})."
        end
      end
    end

    context 'when `type` is `UNAVAILABLE_NAME`' do
      context 'without reference' do
        let(:history_item) { create :history_item, :unavailable_name }

        specify do
          expect(history_item.to_taxt).to eq "Unavailable name."
        end
      end

      context 'with reference' do
        let(:history_item) { create :history_item, :unavailable_name, :with_reference }

        specify do
          expect(history_item.to_taxt).to eq "Unavailable name (#{history_item.citation_taxt})."
        end
      end
    end
  end

  describe '#citation_taxt' do
    context 'with `TAXT` item' do
      let(:history_item) { create :history_item, taxt: "Lectotype designation: {#{Taxt::REF_TAG} 1}: 23" }

      specify { expect { history_item.citation_taxt }.to raise_error('not supported') }
    end

    context 'with relational item' do
      context 'when item supports citations (`reference` + `pages`)' do
        let(:history_item) { create :history_item, :form_descriptions }

        specify do
          expect(history_item.citation_taxt).
            to eq "{#{Taxt::REF_TAG} #{history_item.reference.id}}: #{history_item.pages}"
        end
      end

      context 'when item does not support citations' do
        # For future item types.
      end
    end
  end

  describe '#ids_from_taxon_tags' do
    context 'when taxt contains no tax or taxac tags' do
      let!(:history_item) { create :history_item, :taxt, taxt: 'pizza festival' }

      specify { expect(history_item.ids_from_taxon_tags).to eq [] }
    end

    context 'when taxt contains tax or taxac tags' do
      let(:taxon_1) { create :any_taxon }
      let(:taxon_2) { create :any_taxon }
      let!(:history_item) { create :history_item, :taxt, taxt: "{#{Taxt::TAX_TAG} #{taxon_1.id}}, {#{Taxt::TAXAC_TAG} #{taxon_2.id}}" }

      it 'returns IDs of taxa referenced in tax and taxac tags' do
        expect(history_item.ids_from_taxon_tags).to match_array [taxon_1.id, taxon_2.id]
      end
    end
  end
end
