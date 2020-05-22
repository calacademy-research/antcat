# frozen_string_literal: true

require 'rails_helper'

describe Exporters::Antweb::TaxonomicAttributes do
  describe "#call" do
    # TODO: Temporary backwards-compatability after splitting classes/specs.
    def old_style_array taxon
      hsh = described_class[taxon]
      [
        hsh[:subfamily],
        hsh[:tribe],
        hsh[:genus],
        hsh[:subgenus],
        hsh[:species],
        hsh[:subspecies]
      ]
    end

    describe "[1-6]: `subfamily`, ``tribe, `genus`, `subgenus`, `species` and `subspecies`" do
      let(:subfamily) { create :subfamily }
      let(:tribe) { create :tribe, subfamily: subfamily }

      context 'when taxon is a subfamily' do
        specify do
          expect(old_style_array(subfamily)).to eq [
            subfamily.name_cache, nil, nil, nil, nil, nil
          ]
        end
      end

      context 'when taxon is a genus' do
        context 'when genus has a subfamily and a tribe' do
          let(:taxon) { create :genus, subfamily: subfamily, tribe: tribe }

          specify do
            expect(old_style_array(taxon)).to eq [
              subfamily.name_cache, tribe.name_cache, taxon.name_cache, nil, nil, nil
            ]
          end
        end

        context 'when genus has no subfamily' do
          let(:taxon) { create :genus, tribe: nil, subfamily: nil }

          it "exports the subfamily as 'incertae_sedis'" do
            expect(old_style_array(taxon)).to eq [
              'incertae_sedis', nil, taxon.name_cache, nil, nil, nil
            ]
          end
        end

        context 'when genus has no tribe' do
          let(:taxon) { create :genus, subfamily: subfamily, tribe: nil }

          specify do
            expect(old_style_array(taxon)).to eq [
              subfamily.name_cache, nil, taxon.name_cache, nil, nil, nil
            ]
          end
        end
      end

      context 'when taxon is a subgenus' do
        let(:taxon) { create :subgenus, name_string: 'Atta (Boyo)', subfamily: subfamily }

        it 'exports the subgenus as the subgenus part of the name' do
          expect(old_style_array(taxon)[0]).to eq subfamily.name_cache
          expect(old_style_array(taxon)[3]).to eq 'Boyo'
        end

        context 'when subgenus has no subfamily' do
          let(:taxon) { create :subgenus, subfamily: nil }

          it "exports the subfamily as 'incertae_sedis'" do
            expect(old_style_array(taxon)[0]).to eq 'incertae_sedis'
          end
        end
      end

      context 'when taxon is a species' do
        context 'when species has a subfamily and a tribe' do
          let(:genus) { create :genus, tribe: tribe }
          let(:taxon) { create :species, name_string: 'Atta robustus', genus: genus }

          specify do
            expect(old_style_array(taxon)).to eq [
              subfamily.name_cache, tribe.name_cache, genus.name_cache, nil, 'robustus', nil
            ]
          end
        end

        context 'when species has a subgenus' do
          let(:genus) { create :genus, subfamily: subfamily, tribe: tribe }
          let(:subgenus) { create :subgenus, name_string: 'Atta (Subgenusia)', subfamily: subfamily, tribe: tribe, genus: genus }
          let(:taxon) { create :species, name_string: 'Atta robustus', genus: genus, subgenus: subgenus }

          it 'exports the subgenus as the subgenus part of the name' do
            expect(old_style_array(taxon)).to eq [
              subfamily.name_cache, tribe.name_cache, genus.name_cache, 'Subgenusia', 'robustus', nil
            ]
          end
        end

        context 'when species has no subfamily' do
          let(:genus) { create :genus, subfamily: nil, tribe: nil }
          let(:taxon) { create :species, name_string: 'Atta robustus', genus: genus }

          it "exports the subfamily as 'incertae sedis'" do
            expect(old_style_array(taxon)).to eq [
              'incertae_sedis', nil, genus.name_cache, nil, 'robustus', nil
            ]
          end
        end

        context 'when species has no tribe' do
          let(:genus) { create :genus, subfamily: subfamily, tribe: nil }
          let(:taxon) { create :species, name_string: 'Atta robustus', genus: genus }

          specify do
            expect(old_style_array(taxon)).to eq [
              subfamily.name_cache, nil, genus.name_cache, nil, 'robustus', nil
            ]
          end
        end
      end

      context 'when taxon is a subspecies' do
        context 'when subspecies has a subfamily and a tribe' do
          let(:genus) { create :genus, subfamily: subfamily, tribe: tribe }
          let(:species) { create :species, name_string: 'Atta robustus', subfamily: subfamily, genus: genus }
          let(:taxon) do
            create :subspecies, name_string: 'Atta robustus emeryii', subfamily: subfamily, genus: genus, species: species
          end

          specify do
            expect(old_style_array(taxon)).to eq [
              subfamily.name_cache, tribe.name_cache, genus.name_cache, nil, 'robustus', 'emeryii'
            ]
          end
        end

        context 'when subspecies has a subgenus' do
          let(:genus) { create :genus, subfamily: subfamily, tribe: tribe }
          let(:subgenus) { create :subgenus, name_string: 'Atta (Subgenusia)', subfamily: subfamily, tribe: tribe, genus: genus }
          let(:species) { create :species, name_string: 'Atta robustus', genus: genus, subgenus: subgenus }
          let(:taxon) do
            create :subspecies, name_string: 'Atta robustus emeryii', subfamily: subfamily,
              genus: genus, subgenus: subgenus, species: species
          end

          it 'exports the subgenus as the subgenus part of the name' do
            expect(old_style_array(taxon)).to eq [
              subfamily.name_cache, tribe.name_cache, genus.name_cache, 'Subgenusia', 'robustus', 'emeryii'
            ]
          end
        end

        context 'when subspecies has no subfamily' do
          let(:genus) { create :genus, subfamily: nil, tribe: nil }
          let(:species) { create :species, name_string: 'Atta robustus', subfamily: nil, genus: genus }
          let(:taxon) do
            create :subspecies, name_string: 'Atta robustus emeryii', subfamily: nil, genus: genus, species: species
          end

          it "exports the subfamily as 'incertae sedis'" do
            expect(old_style_array(taxon)).to eq [
              'incertae_sedis', nil, genus.name_cache, nil, 'robustus', 'emeryii'
            ]
          end
        end

        context 'when subspecies has no tribe' do
          let(:genus) { create :genus, subfamily: subfamily, tribe: nil }
          let(:species) { create :species, name_string: 'Atta robustus', subfamily: subfamily, genus: genus }
          let(:taxon) { create :subspecies, name_string: 'Atta robustus emeryii', genus: genus, species: species }

          specify do
            expect(old_style_array(taxon)).to eq [
              subfamily.name_cache, nil, genus.name_cache, nil, 'robustus', 'emeryii'
            ]
          end
        end
      end
    end

    context "when taxon's rank is not exportable" do
      context 'when taxon is a subtribe' do
        let(:taxon) { create :subtribe }

        specify { expect { described_class[taxon].call }.to raise_error("rank 'Subtribe' not supported") }
      end

      context 'when taxon is a infrasubspecies' do
        let(:taxon) { create :infrasubspecies }

        specify { expect { described_class[taxon].call }.to raise_error("rank 'Infrasubspecies' not supported") }
      end
    end
  end
end
