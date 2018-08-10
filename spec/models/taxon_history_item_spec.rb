require 'spec_helper'

describe TaxonHistoryItem do
  it { is_expected.to be_versioned }
  it { is_expected.to validate_presence_of :taxt }
  it { is_expected.to validate_presence_of :taxon_id }
end
