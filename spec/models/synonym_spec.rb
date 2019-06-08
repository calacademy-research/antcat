require 'spec_helper'

describe Synonym do
  describe 'validations' do
    it { is_expected.to be_versioned }
    it { is_expected.to validate_presence_of :junior_synonym }
    it { is_expected.to validate_presence_of :senior_synonym }

    context 'when junior and senior refer the same record' do
      let(:synonym) { build_stubbed :synonym }

      specify do
        expect { synonym.senior_synonym = synonym.junior_synonym }.to change { synonym.valid? }.from(true).to(false)
      end
    end
  end
end
