require 'rails_helper'

describe Protonym do
  it { is_expected.to be_versioned }
  it { is_expected.to validate_presence_of :name }
  it { is_expected.to validate_presence_of :authorship }

  it do
    expect(build_stubbed(:protonym)).to validate_inclusion_of(:biogeographic_region).
      in_array(described_class::BIOGEOGRAPHIC_REGIONS).allow_nil
  end

  describe 'relations' do
    it { is_expected.to belong_to(:name).dependent(:destroy) }
    it { is_expected.to belong_to(:authorship).dependent(:destroy) }
    it { is_expected.to have_many(:taxa).class_name('Taxon').dependent(:restrict_with_error) }
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
end
