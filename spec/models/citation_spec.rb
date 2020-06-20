# frozen_string_literal: true

require 'rails_helper'

describe Citation do
  it { is_expected.to be_versioned }

  describe 'relations' do
    it { is_expected.to have_one(:protonym).dependent(:destroy) }
    it { is_expected.to belong_to(:reference).required }
  end

  describe 'validations' do
    it { is_expected.to validate_presence_of :pages }
  end

  describe 'callbacks' do
    it { is_expected.to strip_attributes(:pages) }
  end
end
