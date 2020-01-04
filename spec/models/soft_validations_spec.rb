require 'rails_helper'

describe SoftValidations do
  # These specs do not really belong here, but it's tested here since the constants are defined in `SoftValidations`.
  describe 'scripts to check' do
    described_class::ALL_DATABASE_SCRIPTS_TO_CHECK.each do |klass|
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

  describe 'testing with a taxon' do
    let(:scripts_to_check) { described_class::TAXA_DATABASE_SCRIPTS_TO_CHECK }

    context 'when taxon is an extant species in a fossil genus' do
      subject(:soft_validations) do
        # NOTE: Defined as a lambda since instance variables are memoized.
        -> { described_class.new(taxon_with_issues, scripts_to_check) }
      end

      let!(:taxon_with_issues) { create :species, name_string: 'Lasius niger', genus: create(:genus, :fossil, name_string: 'Lasius') }

      describe '#all' do
        specify { expect(soft_validations.call.all.size).to eq scripts_to_check.size }
      end

      describe '#failed' do
        let(:failed_soft_validations) { soft_validations.call.failed }

        specify do
          expect(failed_soft_validations.size).to eq 1
          expect(failed_soft_validations.first.database_script).to be_a DatabaseScripts::ExtantTaxaInFossilGenera
        end

        describe 'attributes from `SoftValidation`' do
          specify do
            failed = failed_soft_validations.first

            expect(failed.failed?).to eq true
            expect(failed.database_script).to be_a DatabaseScripts::ExtantTaxaInFossilGenera
            expect(failed.runtime).to be_a Float
            expect(failed.issue_description).to eq DatabaseScripts::ExtantTaxaInFossilGenera.new.issue_description
          end
        end
      end

      describe '#failed?' do
        context 'when taxon is an extant species in a fossil genus' do
          let(:scripts_to_check) do
            [
              DatabaseScripts::ExtantTaxaInFossilGenera,
              DatabaseScripts::TaxaWithNonModernCapitalization
            ]
          end

          specify do
            expect { taxon_with_issues.update!(fossil: true) }.to change { soft_validations.call.failed? }.from(true).to(false)
          end
        end
      end

      describe '#total_runtime' do
        specify { expect(soft_validations.call.total_runtime).to be_a Float }
      end
    end
  end
end
