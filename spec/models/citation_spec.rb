# frozen_string_literal: true

require 'rails_helper'

describe Citation do
  it { is_expected.to be_versioned }

  describe 'relations' do
    it { is_expected.to have_one(:protonym).dependent(:restrict_with_error) }
  end

  describe 'validations' do
    it { is_expected.to validate_presence_of :reference }
    it { is_expected.to validate_presence_of :pages }
  end

  it_behaves_like "a taxt column with cleanup", :notes_taxt do
    subject { build :citation }
  end
end
