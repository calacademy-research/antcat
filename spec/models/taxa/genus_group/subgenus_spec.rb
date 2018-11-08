require 'spec_helper'

describe Subgenus do
  it { is_expected.to validate_presence_of :genus }
end
