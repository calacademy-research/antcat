require 'spec_helper'

describe TaxonState do
  it { is_expected.to validate_inclusion_of(:review_state).in_array(described_class::STATES) }
end
