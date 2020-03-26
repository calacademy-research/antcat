# frozen_string_literal: true

require 'rails_helper'

describe BookReference do
  describe 'validations' do
    it { is_expected.to validate_presence_of :year }
    it { is_expected.to validate_presence_of :publisher }
    it { is_expected.to validate_presence_of :pagination }
  end
end
