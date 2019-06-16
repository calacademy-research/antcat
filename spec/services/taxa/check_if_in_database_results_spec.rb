require 'spec_helper'

describe Taxa::CheckIfInDatabaseResults do
  describe 'DATABASE_SCRIPTS_TO_CHECK' do
    it 'only includes database scripts with `issue_description`s' do
      Taxa::CheckIfInDatabaseResults::DATABASE_SCRIPTS_TO_CHECK.map(&:new).each do |database_script|
        expect(database_script.issue_description.present?).to eq true
      end

      # Sanity check.
      expect(DatabaseScripts::ValidSpeciesList.new.issue_description).to eq nil
    end
  end

  describe '#call' do
    context 'when taxon is a species in a fossil genus' do
      let(:taxon) { create :species, genus: create(:genus, :fossil) }

      specify do
        warning = described_class[taxon].first
        expect(warning[:database_script].class).to eq DatabaseScripts::ExtantTaxaInFossilGenera
        expect(warning[:message]).to eq "The parent of this taxon is fossil, but this taxon is extant."
      end
    end
  end
end
