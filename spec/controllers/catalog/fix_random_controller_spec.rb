require 'spec_helper'

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
end
