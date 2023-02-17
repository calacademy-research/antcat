# frozen_string_literal: true

require 'rails_helper'

describe Exporters::Antweb::History::ChildList do
  include AntwebTestLinksHelpers

  describe '#call' do
    context 'when taxon is a family' do
      let!(:taxon) { create :family }

      context "when family has subfamilies and/or genera incertae sedis in Formicidae" do
        let!(:genus) { create :genus, :incertae_sedis_in_family }

        specify do
          expect(described_class[taxon]).to include "Genera <i>incertae sedis</i> in #{taxon.name_cache}"
        end
      end
    end
  end
end
