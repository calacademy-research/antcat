require 'rails_helper'

describe SoftValidation do
  subject(:soft_validation) { described_class.run(taxon, database_script) }

  let(:database_script) { DatabaseScripts::ExtantTaxaInFossilGenera }

  describe '#issue_description' do
    let(:taxon) { create :family }

    specify { expect(soft_validation.issue_description).to eq database_script.new.issue_description }
  end

  describe '#database_script' do
    let(:taxon) { create :family }

    specify { expect(soft_validation.database_script).to be_a database_script }
  end

  describe '#runtime' do
    let(:taxon) { create :family }

    specify { expect(soft_validation.runtime).to be_a Float }
  end

  describe 'testing with a taxon with issues' do
    context 'when taxon is an extant species in a fossil genus' do
      let(:taxon) { create :species, name_string: 'Lasius niger', genus: create(:genus, :fossil, name_string: 'Lasius') }

      describe '#failed?' do
        specify do
          expect { taxon.update!(fossil: true) }.
            to change { described_class.run(taxon, database_script).failed? }.from(true).to(false)
        end
      end
    end
  end
end
