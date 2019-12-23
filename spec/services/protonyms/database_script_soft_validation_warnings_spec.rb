require 'rails_helper'

describe Protonyms::DatabaseScriptSoftValidationWarnings do
  describe 'DATABASE_SCRIPTS_TO_CHECK' do
    Protonyms::DatabaseScriptSoftValidationWarnings::DATABASE_SCRIPTS_TO_CHECK.each do |klass|
      context klass.name do
        it 'only includes database scripts with `issue_description`s (since issues will be shown in a list)' do
          expect(klass.new.issue_description.present?).to eq true
        end

        it "does not include slow database scripts (since it's checked in the catalog)" do
          expect(klass.new.slow?).to eq false
        end
      end
    end

    # Sanity checks.
    specify { expect(DatabaseScripts::ValidSpeciesList.new.issue_description).to eq nil }
    specify { expect(DatabaseScripts::ValidSpeciesList.new.slow?).to eq true }
  end

  describe '#call' do
    context 'when protonym is orphaned' do
      let!(:protonym) { create :protonym }

      specify do
        expect { create :family, protonym: protonym }.to change { described_class[protonym].size }.by(-1)
      end

      specify do
        warning = described_class[protonym].first
        expect(warning[:database_script].class).to eq DatabaseScripts::OrphanedProtonyms
        expect(warning[:message]).to eq "This protonym is orphaned."
      end
    end
  end
end
