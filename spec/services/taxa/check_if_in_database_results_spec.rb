require 'rails_helper'

describe Taxa::CheckIfInDatabaseResults do
  describe 'DATABASE_SCRIPTS_TO_CHECK' do
    Taxa::CheckIfInDatabaseResults::DATABASE_SCRIPTS_TO_CHECK.each do |klass|
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
    context 'when taxon is an extant species in a fossil genus' do
      let!(:taxon) { create :species, genus: create(:genus, :fossil) }

      specify do
        expect { taxon.update!(fossil: true) }.to change { described_class[taxon].size }.by(-1)
      end

      specify do
        warning = described_class[taxon].first
        expect(warning[:database_script].class).to eq DatabaseScripts::ExtantTaxaInFossilGenera
        expect(warning[:message]).to eq "The parent of this taxon is fossil, but this taxon is extant."
      end
    end
  end
end
