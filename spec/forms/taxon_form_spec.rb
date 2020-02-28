require 'rails_helper'

describe TaxonForm do
  describe "#save" do
    describe "#remove_auto_generated" do
      context "when taxon is updated" do
        let!(:taxon) { create :family, auto_generated: true  }
        let(:taxon_params) { { status: Status::UNAVAILABLE } }

        it "sets `auto_generated` to false'" do
          expect { described_class.new(taxon, taxon_params).save }.
            to change { taxon.reload.auto_generated? }.from(true).to(false)
        end
      end
    end
  end
end
