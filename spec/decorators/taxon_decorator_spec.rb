require 'spec_helper'

describe TaxonDecorator do
  describe "#taxon_status" do
    it "returns 'valid' if the status is valid" do
      taxon = create_genus
      expect(taxon.decorate.taxon_status).to eq 'valid'
    end

    it "shows the status if there is one" do
      taxon = create_genus status: 'homonym'
      expect(taxon.decorate.taxon_status).to eq 'homonym'
    end

    it "shows one synonym" do
      senior_synonym = create_genus 'Atta'
      taxon = create_synonym senior_synonym
      result = taxon.decorate.taxon_status
      expect(result).to eq %{junior synonym of current valid taxon <a href="/catalog/#{senior_synonym.id}"><i>Atta</i></a>}
      expect(result).to be_html_safe
    end

    describe "Using current valid taxon" do
      it "handles a null current valid taxon" do
        senior_synonym = create_genus 'Atta'
        senior_synonym.update_attribute :created_at, Time.now - 100
        other_senior_synonym = create_genus 'Eciton'
        taxon = create_synonym senior_synonym
        Synonym.create! senior_synonym: other_senior_synonym, junior_synonym: taxon
        result = taxon.decorate.taxon_status
        expect(result).to eq %{junior synonym of current valid taxon <a href="/catalog/#{other_senior_synonym.id}"><i>Eciton</i></a>}
      end

      it "handles a null current valid taxon with no synonyms" do
        taxon = create_genus status: 'synonym'
        result = taxon.decorate.taxon_status
        expect(result).to eq %{junior synonym}
      end

      it "handles a current valid taxon that's one of two 'senior synonyms'" do
        senior_synonym = create_genus 'Atta'
        senior_synonym.update_attribute :created_at, Time.now - 100
        other_senior_synonym = create_genus 'Eciton'
        taxon = create_synonym senior_synonym, current_valid_taxon: other_senior_synonym
        Synonym.create! senior_synonym: other_senior_synonym, junior_synonym: taxon
        result = taxon.decorate.taxon_status
        expect(result).to eq %{junior synonym of current valid taxon <a href="/catalog/#{other_senior_synonym.id}"><i>Eciton</i></a>}
      end
    end

    it "doesn't freak out if the senior synonym hasn't been set yet" do
      taxon = create_genus status: 'synonym'
      expect(taxon.decorate.taxon_status).to eq 'junior synonym'
    end

    it "shows where it is incertae sedis" do
      taxon = create_genus incertae_sedis_in: 'family'
      result = taxon.decorate.taxon_status
      expect(result).to eq '<i>incertae sedis</i> in family, valid'
      expect(result).to be_html_safe
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

  describe "#link_to_taxon" do
    it "creates the link" do
      genus = create_genus 'Atta'
      expect(genus.decorate.link_to_taxon).to eq %{<a href="/catalog/#{genus.id}"><i>Atta</i></a>}
    end
  end

  describe "#format_senior_synonym" do
    context "when the senior synonym is itself invalid" do
      it "returns an empty string" do
        invalid_senior = create_genus 'Atta', status: 'synonym'
        junior = create_genus 'Eciton', status: 'synonym'
        Synonym.create! junior_synonym: junior,
          senior_synonym: invalid_senior
        expect(junior.decorate.send(:format_senior_synonym)).to eq ''
      end
    end
  end
end
