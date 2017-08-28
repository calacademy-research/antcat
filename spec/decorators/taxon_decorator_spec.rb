require 'spec_helper'

describe TaxonDecorator do
  describe "#link_to_taxon" do
    let(:genus) { create_genus 'Atta' }

    it "creates the link" do
      expect(genus.decorate.link_to_taxon).to eq %{<a href="/catalog/#{genus.id}"><i>Atta</i></a>}
    end
  end

  describe 'Taxon statistics' do
    it "gets the statistics, then formats them", pending: true do
      pending "test after refactoring TaxonDecorator"
      subfamily = double
      expect(subfamily).to TaxonFormatter(:statistics).and_return extant: :foo
      formatter = Formatters::TaxonFormatter.new subfamily
      expect(Formatters::StatisticsFormatter).to receive(:statistics).with({extant: :foo}, {})
      formatter.statistics
    end

    it "just returns nil if there are no statistics", pending: true do
      pending "test after refactoring TaxonDecorator"
      subfamily = double
      expect(subfamily).to receive(:statistics).and_return nil
      formatter = Formatters::TaxonFormatter.new subfamily
      expect(Formatters::StatisticsFormatter).not_to receive :statistics
      expect(formatter.statistics).to eq ''
    end

    it "doesn't leave a comma at the end if only showing valid taxa", pending: true do
      pending "test after refactoring TaxonDecorator"
      genus = create_genus
      expect(genus).to receive(:statistics).and_return extant: {species: {'valid' => 2}}
      formatter = Formatters::TaxonFormatter.new genus
      expect(formatter.statistics(include_invalid: false))
        .to eq '<div class="statistics"><p class="taxon_statistics">2 species</p></div>'
    end
  end
end
