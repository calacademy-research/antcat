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

  it_behaves_like "a taxt column with cleanup", :notes_taxt do
    subject { build :citation }
  end
end
