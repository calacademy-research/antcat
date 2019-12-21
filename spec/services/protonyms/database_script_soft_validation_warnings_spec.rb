require 'rails_helper'

describe Protonyms::DatabaseScriptSoftValidationWarnings do
  describe 'DATABASE_SCRIPTS_TO_CHECK' do
    Protonyms::DatabaseScriptSoftValidationWarnings::DATABASE_SCRIPTS_TO_CHECK.each do |klass|
      context klass.name do
        it 'only includes database scripts with `issue_description`s (since issues will be shown in a list)' do
          expect(klass.new.issue_description.present?).to eq true
        end
      end
    end

    # Sanity check.
    specify { expect(DatabaseScripts::ValidSpeciesList.new.issue_description).to eq nil }
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
