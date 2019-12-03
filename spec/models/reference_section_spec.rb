require 'rails_helper'

describe ReferenceSection do
  it { is_expected.to be_versioned }
  it { is_expected.to validate_presence_of :taxon }
end
