# frozen_string_literal: true

require 'rails_helper'

describe Notification do
  describe 'relations' do
    it { is_expected.to belong_to(:user).required }
    it { is_expected.to belong_to(:notifier).required }
  end

  describe 'validations' do
    it { is_expected.to validate_presence_of(:attached).on(:create) }
    it { is_expected.to validate_presence_of :reason }
    it { is_expected.to validate_inclusion_of(:reason).in_array(Notification::REASONS) }
  end
end
