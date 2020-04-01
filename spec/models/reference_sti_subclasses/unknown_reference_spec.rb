# frozen_string_literal: true

require 'rails_helper'

describe UnknownReference do
  describe 'validations' do
    it { is_expected.to validate_presence_of :citation }
  end
end
