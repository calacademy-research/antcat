# frozen_string_literal: true

require 'rails_helper'

describe BookReference do
  describe 'relations' do
    it { is_expected.to belong_to(:publisher).required }
  end

  describe 'validations' do
    it { is_expected.to validate_presence_of :year }
    it { is_expected.to validate_presence_of :pagination }
  end
end
