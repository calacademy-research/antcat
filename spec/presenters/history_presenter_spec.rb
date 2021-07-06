# frozen_string_literal: true

require 'rails_helper'

describe HistoryPresenter, :relational_hi do
  subject(:presenter) { described_class.new(protonym.history_items) }

  let(:protonym) { create :protonym }

  describe "#grouped_items" do
    context 'without history items' do
      specify { expect(presenter.grouped_items).to eq [] }
    end

    describe 'grouping items into taxts' do
      context 'with `TAXT` items' do
        let!(:item_1) { create :history_item, :taxt, protonym: protonym }
        let!(:item_2) { create :history_item, :taxt, protonym: protonym }

        it 'does not group them' do
          expect(presenter.grouped_items.map(&:items)).to eq [[item_1], [item_2]]
        end
      end

      context 'with `TYPE_SPECIMEN_DESIGNATION`' do
        context 'with subtype `LECTOTYPE_DESIGNATION`' do
          let!(:item_1) do
            create :history_item, :lectotype_designation, :with_1758_reference, protonym: protonym
          end
          let!(:item_2) do
            create :history_item, :lectotype_designation, :with_2000_reference, protonym: protonym
          end

          it 'does not group them' do
            expect(presenter.grouped_items.map(&:items)).to eq [[item_1], [item_2]]
          end
        end

        context 'with subtype `NEOTYPE_DESIGNATION`' do
          let!(:item_1) do
            create :history_item, :neotype_designation, :with_1758_reference, protonym: protonym
          end
          let!(:item_2) do
            create :history_item, :neotype_designation, :with_2000_reference, protonym: protonym
          end

          it 'does not group them' do
            expect(presenter.grouped_items.map(&:items)).to eq [[item_1], [item_2]]
          end
        end
      end

      context 'with `FORM_DESCRIPTIONS` items' do
        let!(:item_1) { create :history_item, :form_descriptions, :with_2000_reference, protonym: protonym }
        let!(:item_2) { create :history_item, :form_descriptions, :with_1758_reference, protonym: protonym }

        it 'groups them' do
          expect(presenter.grouped_items.map(&:items)).to eq [[item_2, item_1]]
        end
      end

      context 'with `COMBINATION_IN` items' do
        let(:object_taxon) { create :genus }

        let!(:item_1) do
          create :history_item, :combination_in, :with_2000_reference,
            protonym: protonym, object_taxon: object_taxon
        end
        let!(:item_2) do
          create :history_item, :combination_in, :with_1758_reference,
            protonym: protonym, object_taxon: object_taxon
        end

        it 'groups them by `object_taxon`' do
          expect(presenter.grouped_items.map(&:items)).to eq [[item_2, item_1]]
        end
      end

      context 'with `JUNIOR_SYNONYM_OF` items' do
        let(:object_protonym) { create :protonym }

        let!(:item_1) do
          create :history_item, :junior_synonym_of, :with_2000_reference,
            protonym: protonym, object_protonym: object_protonym
        end
        let!(:item_2) do
          create :history_item, :junior_synonym_of, :with_1758_reference,
            protonym: protonym, object_protonym: object_protonym
        end
        let!(:item_3) do
          create :history_item, :junior_synonym_of, :with_1758_reference,
            protonym: protonym
        end

        it 'groups them by `object_protonym`' do
          expect(presenter.grouped_items.map(&:items)).to eq [[item_2, item_1], [item_3]]
        end

        context 'with `object` template' do
          subject(:presenter) { described_class.new(object_protonym.history_items_as_object, :object) }

          it 'groups them by `protonym` (subject protonym)' do
            expect(presenter.grouped_items.map(&:items)).to eq [[item_2, item_1]]
          end
        end
      end

      context 'with `SENIOR_SYNONYM` items' do
        let(:object_protonym) { create :protonym }

        let!(:item_1) do
          create :history_item, :senior_synonym_of, :with_2000_reference,
            protonym: protonym, object_protonym: object_protonym
        end
        let!(:item_2) do
          create :history_item, :senior_synonym_of, :with_1758_reference,
            protonym: protonym, object_protonym: object_protonym
        end

        it 'groups them by `object_protonym`' do
          expect(presenter.grouped_items.map(&:items)).to eq [[item_2, item_1]]
        end
      end

      context 'with `STATUS_AS_SPECIES` items' do
        let!(:item_1) do
          create :history_item, :status_as_species, :with_2000_reference, protonym: protonym
        end
        let!(:item_2) do
          create :history_item, :status_as_species, :with_1758_reference, protonym: protonym
        end

        it 'groups them' do
          expect(presenter.grouped_items.map(&:items)).to eq [[item_2, item_1]]
        end
      end

      context 'with `SUBSPECIES_OF` items' do
        let(:object_protonym) { create :protonym, :species_group }

        let!(:item_1) do
          create :history_item, :subspecies_of, :with_2000_reference,
            protonym: protonym, object_protonym: object_protonym
        end
        let!(:item_2) do
          create :history_item, :subspecies_of, :with_1758_reference,
            protonym: protonym, object_protonym: object_protonym
        end

        it 'groups them by `object_protonym`' do
          expect(presenter.grouped_items.map(&:items)).to eq [[item_2, item_1]]
        end
      end
    end

    describe 'sorting items inside grouped items' do
      context 'when item references have the same year' do
        let!(:item_20001201) do
          reference = create :any_reference, year: 2000, date: '20001201'
          create :history_item, :form_descriptions, protonym: protonym, reference: reference
        end
        let!(:item_20001116) do
          reference = create :any_reference, year: 2000, date: '20001116'
          create :history_item, :form_descriptions, protonym: protonym, reference: reference
        end
        let!(:item_200012) do
          reference = create :any_reference, year: 2000, date: '200012'
          create :history_item, :form_descriptions, protonym: protonym, reference: reference
        end

        it 'uses reference date as the tie-breaker' do
          expect(presenter.grouped_items.map(&:items)).to eq [
            [
              item_20001116,
              item_200012,
              item_20001201
            ]
          ]
        end
      end

      context 'when item references have the same year and date' do
        let!(:item_200011_1) do
          reference = create :any_reference, year: 2000, date: '200011'
          create :history_item, :form_descriptions, protonym: protonym, reference: reference
        end
        let!(:item_200011_2) do
          reference = create :any_reference, year: 2000, date: '200011'
          create :history_item, :form_descriptions, protonym: protonym, reference: reference
        end

        it 'uses reference ID as the tie-breaker' do
          expect(presenter.grouped_items.map(&:items)).to eq [
            [
              item_200011_1,
              item_200011_2
            ]
          ]
        end
      end

      context 'when item references are optional (not required)' do
        let!(:item_1) { create :history_item, :homonym_replaced_by, :with_reference, protonym: protonym }
        let!(:item_2) { create :history_item, :homonym_replaced_by, protonym: protonym }

        it 'can be sorted when compared with items with non-nil references' do
          expect(presenter.grouped_items.map(&:items)).to eq [[item_2], [item_1]]
        end
      end

      context 'with unparsable reference dates' do
        let(:reference_1) { create :any_reference, year: 2001, date: '20010600<' }
        let(:reference_2) { create :any_reference, year: 2001, date: '20010100' }

        let!(:item_1) { create :history_item, :form_descriptions, protonym: protonym, reference: reference_1 }
        let!(:item_2) { create :history_item, :form_descriptions, protonym: protonym, reference: reference_2 }

        it 'positions unparasable dates first' do
          expect(presenter.grouped_items.map(&:taxt)).to eq [
            "#{item_1.citation_taxt} (#{item_1.text_value}); #{item_2.citation_taxt} (#{item_2.text_value})."
          ]
        end
      end
    end

    describe 'sorting grouped taxts' do
      context 'with `TAXT` items' do
        let!(:item_1) { create :history_item, :taxt, taxt: 'pos 3', protonym: protonym }
        let!(:item_2) { create :history_item, :taxt, taxt: 'pos 1', protonym: protonym }
        let!(:item_3) { create :history_item, :taxt, taxt: 'pos 2', protonym: protonym }

        before do
          item_1.update_columns(position: 3)
          item_2.update_columns(position: 1)
          item_3.update_columns(position: 2)
        end

        it 'sort taxt items by their position' do
          # Make sure positions are not auto updated for this spec.
          expect(protonym.history_items.pluck(:id, :position, :taxt)).to eq [
            [item_2.id, 1, 'pos 1'],
            [item_3.id, 2, 'pos 2'],
            [item_1.id, 3, 'pos 3']
          ]

          expect(presenter.grouped_items.map(&:taxt)).to eq [
            'pos 1',
            'pos 2',
            'pos 3'
          ]
        end
      end

      context 'with relational items' do
        let(:object_protonym) { create :protonym }

        let!(:item_1) do
          create :history_item, :senior_synonym_of, protonym: protonym, object_protonym: object_protonym
        end
        let!(:item_2) { create :history_item, :form_descriptions, protonym: protonym }

        it 'sort grouped taxts by their sort definitions' do
          expect(presenter.grouped_items.map(&:taxt)).to eq [
            "#{item_2.citation_taxt} (#{item_2.text_value}).",
            "Senior synonym of {#{Taxt::PROTT_TAG} #{object_protonym.id}}: #{item_1.citation_taxt}."
          ]
        end
      end
    end
  end
end
