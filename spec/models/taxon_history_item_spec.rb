require 'rails_helper'

describe TaxonHistoryItem do
  it { is_expected.to be_versioned }
  it { is_expected.to validate_presence_of :taxt }
  it { is_expected.to validate_presence_of :taxon }

  it_behaves_like "a taxt column with cleanup", :taxt do
    subject { build :taxon_history_item }
  end
end
