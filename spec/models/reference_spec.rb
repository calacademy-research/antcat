# frozen_string_literal: true

require 'rails_helper'

describe Reference do
  it { is_expected.to be_versioned }

  describe 'relations' do
    it { is_expected.to have_many(:reference_author_names).dependent(:destroy) }
    it { is_expected.to have_many(:citations).dependent(:restrict_with_error) }
    it { is_expected.to have_many(:citations_from_type_names).dependent(:restrict_with_error) }
    it { is_expected.to have_many(:history_items).dependent(:restrict_with_error) }
    it { is_expected.to have_many(:nested_references).dependent(:restrict_with_error) }
    it { is_expected.to have_one(:document).dependent(:destroy) }
  end

  describe 'validations' do
    it { is_expected.to validate_presence_of :year }
    it { is_expected.to validate_presence_of :pagination }
    it { is_expected.to validate_presence_of :author_names }
    it { is_expected.to validate_presence_of :title }
    it { is_expected.not_to allow_values('<', '>').for(:doi) }

    it { is_expected.to allow_value('a').for(:year_suffix) }
    it { is_expected.to allow_value(nil).for(:year_suffix) }
    it { is_expected.not_to allow_value('aa').for(:year_suffix) }
    it { is_expected.not_to allow_value('A').for(:year_suffix) }

    describe '#date validations' do
      # TODO: We want to replace the below `describe` with this after clearing `ReferencesWithInvalidDates`.
      # let!(:reference) { build_stubbed :any_reference }
      #
      # specify do
      #   expect { reference.date = '2022-2' }.
      #     to change { reference.valid? }.from(true).to(false)
      #
      #   expect(reference.errors[:date]).to include ReferenceDateFormatValidator::ERROR_MESSAGE
      # end
      describe 'specs to be removed once invalid records have been fixed' do
        context 'with a new reference' do
          let!(:reference) { build :any_reference, date: '20-22-01' }

          it 'validates `date`' do
            expect(reference.valid?).to eq false
            expect(reference.errors[:date]).to include ReferenceDateFormatValidator::ERROR_MESSAGE
          end
        end

        context 'when `date` has been changed' do
          let!(:reference) { create :any_reference, date: '2022-01' }

          it 'validates `date`' do
            expect { reference.date = '2022-2' }.
              to change { reference.valid? }.from(true).to(false)

            expect(reference.errors[:date]).to include ReferenceDateFormatValidator::ERROR_MESSAGE
          end
        end

        context 'when `date` has not been changed' do
          let!(:reference) { create :any_reference }

          before do
            reference.update_columns(date: '20-22-01')
          end

          it 'does not validate `date`' do
            expect { reference.title = 'Changed something' }.not_to change { reference.valid? }.from(true)
          end
        end
      end
    end

    it { is_expected.to validate_inclusion_of(:review_state).in_array(Reference::REVIEW_STATES) }
    it { is_expected.not_to allow_value(nil).for(:review_state) }

    describe '#bolton_key uniqueness validation' do
      let!(:conflict) { create :any_reference, bolton_key: 'Batiatus 2000' }
      let!(:duplicate) { create :any_reference }

      specify do
        expect { duplicate.bolton_key = conflict.bolton_key }.
          to change { duplicate.valid? }.from(true).to(false)
        expect(duplicate.errors[:bolton_key].first).to include "Bolton key has already been taken by"
        expect(duplicate.errors[:bolton_key].first).to include conflict.key_with_suffixed_year
      end
    end
  end

  describe 'callbacks' do
    it { is_expected.to strip_attributes(:public_notes, :editor_notes, :taxonomic_notes) }
    it { is_expected.to strip_attributes(:title, :date, :stated_year, :year_suffix, :bolton_key, :author_names_suffix) }
    it { is_expected.to strip_attributes(:series_volume_issue, :doi, :normalized_bolton_key) }

    describe '#before_update' do
      let!(:reference) { create :article_reference }

      it "invalidates caches" do
        References::Cache::Regenerate[reference]

        expect { reference.save! }.to change { reference.reload.plain_text_cache }.to(nil)
      end

      context "when reference has nested references" do
        let!(:nested_reference) { create :nested_reference, nesting_reference: reference }

        it "nilifies caches for its nested references" do
          expect(reference.reload.nested_references).to eq [nested_reference]

          References::Cache::Regenerate[nested_reference]
          expect(nested_reference.plain_text_cache).not_to eq nil
          expect(nested_reference.expanded_reference_cache).not_to eq nil

          reference.save!
          nested_reference.reload

          expect(nested_reference.plain_text_cache).to eq nil
          expect(nested_reference.expanded_reference_cache).to eq nil
        end
      end
    end
  end

  describe "scopes" do
    describe ".order_by_author_names_and_year" do
      it "sorts by author_name plus year plus letter" do
        one = create :any_reference, author_string: 'Fisher', year: 1910, year_suffix: "b"
        two = create :any_reference, author_string: 'Wheeler', year: 1874
        three = create :any_reference, author_string: 'Fisher', year: 1910, year_suffix: "a"

        expect(described_class.order_by_author_names_and_year).to eq [three, one, two]
      end
    end
  end

  describe '#downloadable?' do
    context 'when referece has a `ReferenceDocument`' do
      let(:reference) { create :any_reference, :with_document }

      specify { expect(reference.downloadable?).to eq true }
    end

    context 'when referece does not have a `ReferenceDocument`' do
      let(:reference) { create :any_reference }

      specify { expect(reference.downloadable?).to eq false }
    end
  end

  describe '#suffixed_year_with_stated_year' do
    context 'when reference does not have a `stated_year`' do
      let(:reference) { create :any_reference, year: 2000, year_suffix: 'a' }

      specify { expect(reference.suffixed_year_with_stated_year).to eq '2000a' }
    end

    context 'when reference has a `stated_year`' do
      let(:reference) { create :any_reference, year: 2000, year_suffix: 'a', stated_year: "2001" }

      specify { expect(reference.suffixed_year_with_stated_year).to eq '2000a ("2001")' }
    end
  end

  describe "#author_names_string" do
    context "when reference has one author name" do
      let(:reference) { create :any_reference, author_string: 'Fisher, B.L.' }

      it 'returns the author name' do
        expect(reference.author_names_string).to eq 'Fisher, B.L.'
      end
    end

    context "when reference has more than one author name" do
      let(:reference) { create :any_reference, author_string: ['Fisher, B.L.', 'Ward, P.S.'] }

      it "separates multiple author names with semicolons" do
        expect(reference.author_names_string).to eq 'Fisher, B.L.; Ward, P.S.'
      end
    end
  end

  describe "#author_names_string_with_suffix" do
    context "when reference has an `author_names_suffix`" do
      let(:reference) { create :any_reference, author_string: 'Fisher, B.L.', author_names_suffix: '(ed.)' }

      it "includes the `author_names_suffix` after the author names" do
        expect(reference.author_names_string_with_suffix).to eq 'Fisher, B.L. (ed.)'
      end
    end
  end

  describe "#refresh_author_names_cache!" do
    context "when an author name is added" do
      let(:reference) { create :any_reference, author_string: 'Fisher, B.L.' }

      it "updates its `author_names_string`" do
        reference.author_names << create(:author_name, name: 'Ward, P.S.')

        expect { reference.refresh_author_names_cache! }.
          to change { reference.reload.author_names_string }.
          from('Fisher, B.L.').to('Fisher, B.L.; Ward, P.S.')
      end
    end
  end

  describe "#refresh_key_with_suffixed_year_cache!" do
    context "when an author name is added" do
      let(:reference) { create :any_reference, author_string: 'Fisher, B.L.', year: 2000, year_suffix: 'b' }

      it "updates its `key_with_suffixed_year_cache`" do
        reference.author_names << create(:author_name, name: 'Ward, P.S.')

        expect { reference.refresh_key_with_suffixed_year_cache! }.
          to change { reference.reload.key_with_suffixed_year_cache }.
          from("Fisher, 2000b").to("Fisher & Ward, 2000b")
      end
    end
  end
end
