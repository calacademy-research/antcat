# frozen_string_literal: true

require 'rails_helper'

describe Protonym do
  it { is_expected.to be_versioned }

  describe 'relations' do
    it { is_expected.to belong_to(:name).dependent(:destroy) }
    it { is_expected.to belong_to(:name).required }
    it { is_expected.to belong_to(:authorship).dependent(:destroy) }
    it { is_expected.to belong_to(:authorship).required }
    it { is_expected.to have_many(:taxa).class_name('Taxon').dependent(:restrict_with_error) }
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
  end

  describe 'callbacks' do
    it { is_expected.to strip_attributes(:locality, :biogeographic_region, :forms, :notes_taxt) }
    it { is_expected.to strip_attributes(:primary_type_information_taxt, :secondary_type_information_taxt, :type_notes_taxt) }

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
    let!(:reference) { create :any_reference, author_string: 'Bolton', citation_year: '2005b' }
    let!(:protonym) { create :protonym, authorship: create(:citation, reference: reference) }

    it 'does not include letters from the `citation_year`' do
      expect(protonym.author_citation).to eq 'Bolton, 2005'
    end
  end
end
