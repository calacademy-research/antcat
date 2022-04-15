# frozen_string_literal: true

require 'rails_helper'

describe TaxonForm do
  describe "#save" do
    describe "creating a new `Protonym`" do
      context 'with passing validations' do
        let(:taxon) { Taxa::BuildTaxon[Rank::SUBFAMILY, create(:family)] }
        let(:params) do
          {
            status: Status::VALID,
            protonym_attributes: {
              authorship_attributes: {
                reference_id: create(:any_reference).id,
                pages: '99'
              }
            }
          }
        end

        it 'creates a new `Protonym`' do
          form = described_class.new(
            taxon,
            params,
            taxon_name_string: "Attainae",
            protonym_name_string: "Attainae"
          )

          expect { form.save }.to change { Protonym.count }
        end
      end

      context 'with failing validations' do
        let(:taxon) { Taxa::BuildTaxon[Rank::SUBFAMILY, create(:family)] }
        let(:params) do
          {
            status: Status::VALID,
            protonym_attributes: {
              fossil: true,
              bioregion: Protonym::NEARCTIC_REGION,
              authorship_attributes: {
                reference_id: create(:any_reference).id,
                pages: '99'
              }
            }
          }
        end

        it 'does not create a new `Protonym`' do
          form = described_class.new(
            taxon,
            params,
            taxon_name_string: "Attainae",
            protonym_name_string: "Attainae"
          )

          expect { form.save }.not_to change { Protonym.count }
          expect(form.errors[:base]).to include "Protonym: Bioregion cannot be set for fossil protonyms"
        end
      end
    end
  end
end
