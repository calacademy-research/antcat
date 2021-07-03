# frozen_string_literal: true

require 'rails_helper'

describe AuthorName do
  it { is_expected.to be_versioned }

  describe 'relations' do
    it { is_expected.to have_many(:reference_author_names).dependent(:restrict_with_error) }
    it { is_expected.to have_many(:references).dependent(:restrict_with_error) }
    it { is_expected.to belong_to(:author).required }
  end

  describe 'validations' do
    it { is_expected.to validate_presence_of :name }
    it { is_expected.to validate_length_of(:name).is_at_least(described_class::NAME_MIN_LENGTH) }

    describe 'allowed characters' do
      it 'allows diacritics, apostrophes and hyphens' do
        is_expected.to allow_value('André, Edm.').for(:name)
        is_expected.to allow_value('Depa, Ł.').for(:name)

        is_expected.to allow_value("O'Donnell, S.").for(:name)
        is_expected.to allow_value('Israel Kamakawiwoʻole').for(:name)
        is_expected.to allow_value('Kim, J.-H.').for(:name)
      end

      # TODO: Probably do not allow this.
      it 'allows Unicode Mark diacritics' do
        is_expected.to allow_value("Guénard, B.").for(:name)
      end

      it 'does not allow digits or weird characters' do
        error_message = "contains unsupported characters"

        is_expected.to_not allow_value('Author1, A.').for(:name).with_message(error_message)
        is_expected.to_not allow_value('Author; A.').for(:name).with_message(error_message)
        is_expected.to_not allow_value('Author, A. & Author, B.').for(:name).with_message(error_message)
      end
    end

    describe "uniqueness validation" do
      subject { create :author_name }

      it { is_expected.to validate_uniqueness_of(:name).ignoring_case_sensitivity }
    end
  end

  describe 'callbacks' do
    describe '#invalidate_reference_caches' do
      let!(:author_name) { create :author_name, name: 'Ward' }
      let!(:reference) { create :any_reference, author_names: [author_name] }

      it "refreshes `author_names_string_cache` its references" do
        expect { author_name.update!(name: 'Fisher') }.
          to change { reference.reload.author_names_string }.from('Ward').to('Fisher')
      end

      it "invalidates caches for its references" do
        References::Cache::Regenerate[reference]
        expect { author_name.save! }.to change { reference.reload.plain_text_cache }.to(nil)
      end
    end
  end

  describe "#last_name and #first_name_and_initials" do
    context "when there's only one word" do
      let(:author_name) { described_class.new(name: 'Bolton') }

      it "returns the name as the last name" do
        expect(author_name.last_name).to eq 'Bolton'
        expect(author_name.first_name_and_initials).to eq nil
      end
    end

    context 'when there are multiple words' do
      let(:author_name) { described_class.new(name: 'Bolton, B.L.') }

      it "separates the words" do
        expect(author_name.last_name).to eq 'Bolton'
        expect(author_name.first_name_and_initials).to eq 'B.L.'
      end
    end

    context 'when there is no comma' do
      let(:author_name) { described_class.new(name: 'Royal Academy') }

      it "uses all words" do
        expect(author_name.last_name).to eq 'Royal Academy'
        expect(author_name.first_name_and_initials).to eq nil
      end
    end

    context 'when there are multiple commas' do
      let(:author_name) { described_class.new(name: 'Baroni Urbani, C.') }

      it "uses all words before the comma" do
        expect(author_name.last_name).to eq 'Baroni Urbani'
        expect(author_name.first_name_and_initials).to eq 'C.'
      end
    end
  end
end
