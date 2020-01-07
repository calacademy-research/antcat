require 'rails_helper'

describe Citation do
  it { is_expected.to be_versioned }
  it { is_expected.to validate_presence_of :reference }
  it { is_expected.to validate_presence_of :pages }

  describe 'relations' do
    it { is_expected.to have_one(:protonym).dependent(:restrict_with_error) }
  end

  it_behaves_like "a taxt column with cleanup", :notes_taxt do
    subject { build :citation }
  end
end
