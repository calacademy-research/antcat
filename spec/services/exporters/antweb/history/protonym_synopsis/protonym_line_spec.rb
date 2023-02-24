# frozen_string_literal: true

require 'rails_helper'

describe Exporters::Antweb::History::ProtonymSynopsis::ProtonymLine do
  include AntwebTestLinksHelpers

  describe "#call" do
    let(:taxt_taxon) { create :any_taxon }
    let(:protonym) do
      create :protonym, :species_group, locality: 'Indonesia (Timor)',
        forms: 'w.', notes_taxt: "see #{Taxt.tax(taxt_taxon.id)}"
    end

    specify do
      expect(described_class[protonym]).to eq(
        "<b><i>#{protonym.name.name}</i></b> " \
        "#{antweb_reference_link(protonym.authorship_reference)}: " \
        "#{protonym.decorate.format_pages_and_forms} " \
        "see #{antweb_taxon_link(taxt_taxon)} " \
        "#{protonym.decorate.format_locality}."
      )
    end
  end
end
