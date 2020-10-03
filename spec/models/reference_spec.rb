# frozen_string_literal: true

require 'rails_helper'

describe Reference do
  it { is_expected.to be_versioned }
  it { is_expected.to delegate_method(:routed_url).to(:document).allow_nil }
  it { is_expected.to delegate_method(:downloadable?).to(:document).allow_nil }

  describe 'relations' do
    it { is_expected.to have_many(:reference_author_names).dependent(:destroy) }
    it { is_expected.to have_many(:citations).dependent(:restrict_with_error) }
    it { is_expected.to have_many(:citations_from_type_names).dependent(:restrict_with_error) }
    it { is_expected.to have_many(:nestees).dependent(:restrict_with_error) }
    it { is_expected.to have_one(:document).dependent(false) }
  end

  describe 'validations' do
    it { is_expected.to validate_presence_of :year }
    it { is_expected.to validate_presence_of :pagination }
    it { is_expected.to validate_presence_of :author_names }
    it { is_expected.to validate_presence_of :title }
    it { is_expected.to_not allow_values('<', '>').for(:doi) }

    it { is_expected.to allow_value('a').for(:year_suffix) }
    it { is_expected.to_not allow_value('aa').for(:year_suffix) }
    it { is_expected.to_not allow_value('A').for(:year_suffix) }

    describe '`bolton_key` uniqueness' do
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
    it { is_expected.to strip_attributes(:series_volume_issue, :doi) }
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

  describe 'workflow' do
    let(:reference) { create :any_reference }

    describe 'default state' do
      it "starts as 'none'" do
        expect(reference.none?).to eq true
        expect(reference.reviewing?).to eq false
        expect(reference.reviewed?).to eq false

        expect(reference.can_start_reviewing?).to eq true
        expect(reference.can_finish_reviewing?).to eq false
        expect(reference.can_restart_reviewing?).to eq false
      end
    end

    describe '#start_reviewing!' do
      it "transitions from 'none' to 'reviewing'" do
        expect { reference.start_reviewing! }.to change { reference.reviewing? }.to(true)

        expect(reference.can_start_reviewing?).to eq false
        expect(reference.can_finish_reviewing?).to eq true
        expect(reference.can_restart_reviewing?).to eq false
      end
    end

    describe '#finish_reviewing!' do
      before do
        reference.start_reviewing!
      end

      it "transitions from 'reviewing' to 'reviewed'" do
        expect { reference.finish_reviewing! }.to change { reference.reviewed? }.to(true)

        expect(reference.can_start_reviewing?).to eq false
        expect(reference.can_finish_reviewing?).to eq false
        expect(reference.can_restart_reviewing?).to eq true
      end
    end

    describe '#restart_reviewing!' do
      before do
        reference.start_reviewing!
        reference.finish_reviewing!
      end

      it "can transition 'reviewed' back to 'reviewing'" do
        expect { reference.restart_reviewing! }.to change { reference.reviewing? }.to(true)

        expect(reference.can_start_reviewing?).to eq false
        expect(reference.can_finish_reviewing?).to eq true
        expect(reference.can_restart_reviewing?).to eq false
      end
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
end
