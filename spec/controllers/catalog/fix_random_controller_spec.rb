require 'rails_helper'

describe Catalog::FixRandomController do
  describe 'DATABASE_SCRIPTS_TO_CHECK' do
    it 'only includes database scripts also in `DATABASE_SCRIPTS_TO_CHECK` (to make issues visible in catalog pages)' do
      randomizable = described_class::DATABASE_SCRIPTS_TO_CHECK
      soft_validated = Taxa::CheckIfInDatabaseResults::DATABASE_SCRIPTS_TO_CHECK
      expect(randomizable - soft_validated).to eq []

      # Sanity check.
      expect([DatabaseScripts::OrphanedProtonyms] - soft_validated).to_not eq []
    end
  end

  describe "GET show" do
    context 'when there are no randomizable ants' do
      specify { expect(get(:show)).to redirect_to database_scripts_path }
    end
  end
end
