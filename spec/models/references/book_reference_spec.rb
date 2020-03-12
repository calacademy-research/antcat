require 'rails_helper'

describe BookReference do
  it { is_expected.to validate_presence_of :year }
  it { is_expected.to validate_presence_of :publisher }
  it { is_expected.to validate_presence_of :pagination }
end
