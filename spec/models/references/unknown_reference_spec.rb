require 'spec_helper'

describe UnknownReference do
  it { is_expected.to validate_presence_of :year }
  it { is_expected.to validate_presence_of :citation }
end
