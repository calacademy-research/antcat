# frozen_string_literal: true

require 'rails_helper'

describe Exporters::Antweb::TaxonomicAttributes do
  describe 'constants' do
    specify do
      expect(described_class::INCERTAE_SEDIS).to eq 'incertae_sedis'
      expect(described_class::FORMICIDAE).to eq 'Formicidae'
    end
  end

  describe "#call" do
    describe "[1-6]: `subfamily`, `tribe, `genus`, `subgenus`, `species` and `subspecies`" do
      let(:subfamily) { create :subfamily }
      let(:tribe) { create :tribe, subfamily: subfamily }

      context 'when taxon is a family' do
        let(:taxon) { create :family }

        specify do
          expect(described_class[taxon]).to eq(
            subfamily: described_class::FORMICIDAE
          )
        end
      end

      context 'when taxon is a subfamily' do
        specify do
          expect(described_class[subfamily]).to eq(
            subfamily: subfamily.name_cache
          )
        end
      end

      context 'when taxon is a genus' do
        context 'when genus has a subfamily and a tribe' do
          let(:taxon) { create :genus, subfamily: subfamily, tribe: tribe }

          specify do
            expect(described_class[taxon]).to eq(
              subfamily: subfamily.name_cache,
              tribe: tribe.name_cache,
              genus: taxon.name_cache
            )
          end
        end

        context 'when genus has no subfamily' do
          let(:taxon) { create :genus, tribe: nil, subfamily: nil }

          it "exports the subfamily as 'incertae_sedis'" do
            expect(described_class[taxon][:subfamily]).to eq described_class::INCERTAE_SEDIS
          end
        end

        context 'when genus has no tribe' do
          let(:taxon) { create :genus, subfamily: subfamily, tribe: nil }

          specify do
            expect(described_class[taxon]).to eq(
              subfamily: subfamily.name_cache,
              tribe: nil,
              genus: taxon.name_cache
            )
          end
        end
      end

      context 'when taxon is a subgenus' do
        let(:genus) { create :genus, subfamily: subfamily }
        let(:taxon) { create :subgenus, name_string: 'Atta (Boyo)', subfamily: subfamily, genus: genus }

        specify do
          expect(described_class[taxon]).to eq(
            subfamily: subfamily.name_cache,
            genus: genus.name_cache,
            subgenus: 'Boyo'
          )
        end

        it 'exports the subgenus as the subgenus part of the name' do
          expect(described_class[taxon][:subgenus]).to eq 'Boyo'
        end

        context 'when subgenus has no subfamily' do
          let(:taxon) { create :subgenus, subfamily: nil }

          it "exports the subfamily as 'incertae_sedis'" do
            expect(described_class[taxon][:subfamily]).to eq described_class::INCERTAE_SEDIS
          end
        end
      end

      context 'when taxon is a species' do
        context 'when species has a subfamily and a tribe' do
          let(:genus) { create :genus, tribe: tribe }
          let(:taxon) { create :species, name_string: 'Atta robustus', genus: genus }

          specify do
            expect(described_class[taxon]).to eq(
              subfamily: subfamily.name_cache,
              tribe: tribe.name_cache,
              genus: genus.name_cache,
              subgenus: nil,
              species: 'robustus'
            )
          end
        end

        context 'when species has a subgenus' do
          let(:genus) { create :genus, subfamily: subfamily, tribe: tribe }
          let(:subgenus) { create :subgenus, name_string: 'Atta (Subgenusia)', subfamily: subfamily, tribe: tribe, genus: genus }
          let(:taxon) { create :species, name_string: 'Atta robustus', genus: genus, subgenus: subgenus }

          it 'exports the subgenus as the subgenus part of the name' do
            expect(described_class[taxon][:subgenus]).to eq 'Subgenusia'
          end
        end

        context 'when species has no subfamily' do
          let(:genus) { create :genus, subfamily: nil, tribe: nil }
          let(:taxon) { create :species, name_string: 'Atta robustus', genus: genus }

          it "exports the subfamily as 'incertae sedis'" do
            expect(described_class[taxon][:subfamily]).to eq described_class::INCERTAE_SEDIS
          end
        end

        context 'when species has no tribe' do
          let(:genus) { create :genus, subfamily: subfamily, tribe: nil }
          let(:taxon) { create :species, name_string: 'Atta robustus', genus: genus }

          specify do
            expect(described_class[taxon][:tribe]).to eq nil
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
            expect(described_class[taxon]).to eq(
              subfamily: subfamily.name_cache,
              tribe: tribe.name_cache,
              genus: genus.name_cache,
              subgenus: nil,
              species: 'robustus',
              subspecies: 'emeryii'
            )
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
            expect(described_class[taxon][:subgenus]).to eq 'Subgenusia'
          end
        end

        context 'when subspecies has no subfamily' do
          let(:genus) { create :genus, subfamily: nil, tribe: nil }
          let(:species) { create :species, name_string: 'Atta robustus', subfamily: nil, genus: genus }
          let(:taxon) do
            create :subspecies, name_string: 'Atta robustus emeryii', subfamily: nil, genus: genus, species: species
          end

          it "exports the subfamily as 'incertae sedis'" do
            expect(described_class[taxon][:subfamily]).to eq described_class::INCERTAE_SEDIS
          end
        end

        context 'when subspecies has no tribe' do
          let(:genus) { create :genus, subfamily: subfamily, tribe: nil }
          let(:species) { create :species, name_string: 'Atta robustus', subfamily: subfamily, genus: genus }
          let(:taxon) { create :subspecies, name_string: 'Atta robustus emeryii', genus: genus, species: species }

          specify do
            expect(described_class[taxon][:tribe]).to eq nil
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
