require 'spec_helper'

describe TaxonDecorator do
  describe "Header formatting" do
    let(:decorator_helper) { TaxonDecorator::Header }

    describe "#link_each_epithet" do
      it "formats a subspecies with > 3 epithets" do
        formica = create_genus 'Formica'
        rufa = create_species 'rufa', genus: formica
        major_name = Name.create! name: 'Formica rufa pratensis major',
          epithet_html: '<i>major</i>',
          epithets: 'rufa pratensis major'
        major = create_subspecies name: major_name, species: rufa, genus: rufa.genus

        expect(decorator_helper.new(major).send(:link_each_epithet)).to eq(
          %{<a href="/catalog/#{formica.id}"><i>Formica</i></a> } +
          %{<a href="/catalog/#{rufa.id}"><i>rufa</i></a> } +
          %{<a href="/catalog/#{major.id}"><i>pratensis major</i></a>}
        )
      end
    end
  end

  describe "Headline formatting" do
    let(:decorator_helper) { TaxonDecorator::Headline }

    describe "#protonym_name" do
      it "formats a family name in the protonym" do
        protonym = create :protonym, name: create(:subfamily_name, name: 'Dolichoderinae')
        expect(decorator_helper.new(nil).send(:protonym_name, protonym))
          .to eq '<b><span>Dolichoderinae</span></b>'
      end

      it "formats a genus name in the protonym" do
        protonym = create :protonym, name: create(:genus_name, name: 'Atari')
        expect(decorator_helper.new(nil).send(:protonym_name, protonym))
          .to eq '<b><span><i>Atari</i></span></b>'
      end

      it "formats a fossil" do
        protonym = create :protonym, name: create(:genus_name, name: 'Atari'), fossil: true
        expect(decorator_helper.new(nil).send(:protonym_name, protonym))
          .to eq '<b><span><i>&dagger;</i><i>Atari</i></span></b>'
      end
    end

    describe "types" do
      let(:species_name) { create :species_name, name: 'Atta major', epithet: 'major' }

      describe "#headline_type" do
        it "shows the type taxon" do
          genus = create_genus 'Atta', type_name: species_name
          expect(decorator_helper.new(genus).send(:headline_type))
            .to eq %{<span>Type-species: <span><i>Atta major</i></span>.</span>}
        end

        it "shows the type taxon with extra Taxt" do
          genus = create_genus 'Atta', type_name: species_name, type_taxt: ', by monotypy'
          expect(decorator_helper.new(genus).send(:headline_type))
            .to eq %{<span>Type-species: <span><i>Atta major</i></span>, by monotypy.</span>}
        end
      end

      describe "#headline_type_name" do
        it "shows the type taxon as a link, if the taxon for the name exists" do
          type = create_species 'Atta major'
          genus = create_genus 'Atta', type_name: create(:species_name, name: 'Atta major')
          expect(decorator_helper.new(genus).send(:headline_type_name))
            .to eq %Q{<a href="/catalog/#{type.id}"><i>Atta major</i></a>}
        end
      end
    end

    describe "#link_to_other_site" do
      it "links to species" do
        subfamily = create_subfamily 'Dolichoderinae'
        genus = create_genus 'Atta', subfamily: subfamily
        species = create_species 'Atta major', genus: genus, subfamily: subfamily
        expect(decorator_helper.new(species).send(:link_to_other_site)).to eq %{<a class="link_to_external_site" href="http://www.antweb.org/description.do?rank=species&genus=atta&species=major&project=worldants">AntWeb</a>}
      end

      it "links to subspecies" do
        subfamily = create_subfamily 'Dolichoderinae'
        genus = create_genus 'Atta', subfamily: subfamily
        species = create_species 'Atta major', genus: genus, subfamily: subfamily
        species = create_subspecies 'Atta major nigrans', species: species, genus: genus, subfamily: subfamily
        expect(decorator_helper.new(species).send(:link_to_other_site))
          .to eq %{<a class="link_to_external_site" href="http://www.antweb.org/description.do?rank=subspecies&genus=atta&species=major&subspecies=nigrans&project=worldants">AntWeb</a>}
      end

      it "links to invalid taxa" do
        subfamily = create_subfamily 'Dolichoderinae', status: 'synonym'
        expect(decorator_helper.new(subfamily).send(:link_to_other_site)).not_to be_nil
      end
    end
  end

  describe "Child lists" do
    let(:decorator_helper) { TaxonDecorator::ChildList }
    let(:subfamily) { create_subfamily 'Dolichoderinae' }

    describe "#child_list" do
      it "formats a tribes list" do
        attini = create_tribe 'Attini', subfamily: subfamily
        expect(decorator_helper.new(subfamily).send(:child_list, subfamily.tribes, true))
          .to eq %{<div><span class="caption">Tribe (extant) of <span>Dolichoderinae</span></span>: <a href="/catalog/#{attini.id}">Attini</a>.</div>}
      end

      it "formats a child list, specifying extinctness" do
        atta = create_genus 'Atta', subfamily: subfamily
        expect(decorator_helper.new(subfamily).send(:child_list, Genus.all, true))
          .to eq %{<div><span class="caption">Genus (extant) of <span>Dolichoderinae</span></span>: <a href="/catalog/#{atta.id}"><i>Atta</i></a>.</div>}
      end

      it "formats a genera list, not specifying extinctness" do
        atta = create_genus 'Atta', subfamily: subfamily
        expect(decorator_helper.new(subfamily).send(:child_list, Genus.all, false))
          .to eq %{<div><span class="caption">Genus of <span>Dolichoderinae</span></span>: <a href="/catalog/#{atta.id}"><i>Atta</i></a>.</div>}
      end

      it "formats an incertae sedis genera list" do
        genus = create_genus 'Atta', subfamily: subfamily, incertae_sedis_in: 'subfamily'
        expect(decorator_helper.new(subfamily).send(:child_list, [genus], false, incertae_sedis_in: 'subfamily'))
          .to eq %{<div><span class="caption">Genus <i>incertae sedis</i> in <span>Dolichoderinae</span></span>: <a href="/catalog/#{genus.id}"><i>Atta</i></a>.</div>}
      end
    end

    describe "#collective_group_name_child_list" do
      it "formats a list of collective group names" do
        genus = create_genus 'Atta', subfamily: subfamily, status: 'collective group name'
        expect(decorator_helper.new(subfamily).send(:collective_group_name_child_list))
          .to eq %{<div><span class="caption">Collective group name in <span>Dolichoderinae</span></span>: <a href="/catalog/#{genus.id}"><i>Atta</i></a>.</div>}
      end
    end

    describe "#child_list_query" do
      let!(:subfamily) { create :subfamily, name: create(:name, name: 'Dolichoderinae') }

      it "finds all genera for the taxon if there are no conditions" do
        create :genus, name: create(:name, name: 'Atta'),
          subfamily: subfamily
        create :genus, name: create(:name, name: 'Eciton'),
          subfamily: subfamily, fossil: true
        create :genus, name: create(:name, name: 'Aneuretus'),
          subfamily: subfamily, fossil: true, incertae_sedis_in: 'subfamily'

        results = decorator_helper.new(subfamily).send :child_list_query, :genera
        expect(results.map(&:name).map(&:to_s).sort).to eq ['Aneuretus', 'Atta', 'Eciton']

        results = decorator_helper.new(subfamily).send :child_list_query, :genera, fossil: true
        expect(results.map(&:name).map(&:to_s).sort).to eq ['Aneuretus', 'Eciton']

        results = decorator_helper.new(subfamily).send :child_list_query, :genera, incertae_sedis_in: 'subfamily'
        expect(results.map(&:name).map(&:to_s).sort).to eq ['Aneuretus']
      end

      it "doesn't include invalid taxa" do
        create :genus, name: create(:name, name: 'Atta'),
          subfamily: subfamily, status: 'synonym'
        create :genus, name: create(:name, name: 'Eciton'),
          subfamily: subfamily, fossil: true
        create :genus, name: create(:name, name: 'Aneuretus'),
          subfamily: subfamily, fossil: true, incertae_sedis_in: 'subfamily'

        results = decorator_helper.new(subfamily).send :child_list_query, :genera
        expect(results.map(&:name).map(&:to_s).sort).to eq ['Aneuretus', 'Eciton']
      end
    end
  end

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
