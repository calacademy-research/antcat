# coding: UTF-8
require 'spec_helper'

describe Importers::Bolton::Catalog::Subfamily::Importer do
  before do
    @importer = Importers::Bolton::Catalog::Subfamily::Importer.new
  end

  describe "Importing HTML" do

    before do
      FactoryGirl.create :article_reference, :author_names => [FactoryGirl.create(:author_name, :name => 'Latreille, I.')], :citation_year => '1809', :title => 'Ants', :bolton_key_cache => 'Latreille 1809'
      Family.import(
        :protonym => {
          :family_or_subfamily_name => "Formicariae",
          :authorship => [{:author_names => ["Latreille"], :year => "1809", :pages => "124"}],
        },
        :type_genus => {:genus_name => 'Formica'},
        :history => ['Taxonomic history']
      )
      allow(@importer).to receive :parse_family
    end

    def make_contents content
      %{<html><body><div><p>THE DOLICHODEROMORPHS: SUBFAMILIES ANEURETINAE AND DOLICHODERINAE</p>#{content}</div></body></html>}
    end

    it "should import a subfamily" do
      emery = FactoryGirl.create :article_reference, bolton_key_cache: 'Emery 1913a'
      @importer.import_html make_contents %{
        <p>SUBFAMILY ANEURETINAE</p>
        <p>Subfamily ANEURETINAE </p>
        <p>Aneuretini Emery, 1913a: 6. Type-genus: <i>Aneuretus</i>.</p>

        <p>Taxonomic history</p>
        <p>Aneuretinae as junior synonym of Dolichoderinae: Baroni Urbani, 1989: 147.</p>

        <p>Tribes of Aneuretinae: Aneuretini, *Pityomyrmecini.</p>
        <p>Tribes <i>incertae sedis</i> in Aneuretinae: *Miomyrmecini.</p>
        <p>Genera (extinct) <i>incertae sedis</i> in Aneuretinae: *<i>Burmomyrma, *Cananeuretus</i>. </p>
        <p>Genus <i>incertae sedis</i> in Aneuretinae: <i>Wildensis</i>. </p>
        <p>Hong (2002) genera (extinct) <i>incertae sedis</i> in Aneuretinae: *<i>Curtipalpulus, *Eoleptocerites</i> (unresolved junior homonym).</p>

        <p>Tribe ANEURETINI</p>
        <p>Aneuretini Emery, 1913a: 6. Type-genus: <i>Aneuretus</i>.</p>
        <p>Taxonomic history</p>
        <p>history</p>

        <p>Junior synonyms of ANEURETINI</p>
        <p>Anonychomyrmini Donisthorpe, 1947c: 588. Type-genus: <i>Anonychomyrma</i>.</p>
        <p>Taxonomic history</p>
        <p>Anonychomyrmini as tribe of Dolichoderinae: Donisthorpe, 1947c: 588.</p>

        <p>Subfamily, tribe Aneuretini and genus <i>Aneuretus</i> references</p>
        <p>Emery, 1913a: 461 (diagnosis)</p>

        <p>Genera of Aneuretini</p>

        <p>Genus <i>ANEURETUS</i></p>
        <p><i>Aneuretus</i> Dlussky, 1988: 54. Type-species: *<i>Aneuretus deformis</i>, by original designation.</p>
        <p>Taxonomic history</p>
        <p>Aneuretus history</p>

        <p>Junior synonyms of <i>ANEURETUS</i></p>
        <p><i>Odontomyrmex</i> André, 1905: 207. Type-species: <i>Odontomyrmex quadridentatus</i>, by monotypy. </p>
        <p>Taxonomic history</p>
        <p>Odontomyrmex history</p>

        <p>Homonym replaced by <i>Odontomyrmex</i></p>
        <p><i>Diabolus</i> Roger, 1863a: 166. Type-species: <i>Diabolous nigella</i>, by monotypy. </p>
        <p>Taxonomic history</p>
        <p>Diabolous history</p>

        <p>Genus <i>Aneuretus</i> references</p>
        <p><i>Aneuretus</i> reference</p>

        <p>Genera <i>incertae sedis</i> in ANEURETINAE</p>
        <p>Genus *<i>BURMOMYRMA</i></p>
        <p>*<i>Burmomyrma</i> Dlussky, 1996: 87. Type-species: *<i>Burmomyrma rossi</i>, by original designation.</p>
        <p>Taxonomic history</p>
        <p>History</p>

        <p>Genera of Hong (2002), <i>incertae sedis</i> in ANEURETINAE</p>
        <p>Genus *<i>WILSONIA</i></p>
        <p>*<i>Wilsonia</i> Hong, 2002: 608. Type-species: *<i>Wilsonia megagastrosa</i>, by original designation. </p>
        <p>Taxonomic history</p>
        <p>History</p>

        <p>Collective group name in ANEURETINAE</p>
        <p>*<i>MYRMECIITES</i></p>
        <p>*<i>Myrmeciites </i>Archibald, Cover &amp; Moreau, 2006: 500. [Collective group name.]</p>
        <p>Taxonomic history</p>
        <p>*<i>Myrmeciites incertae sedis</i> in Hymenoptera: Baroni Urbani, 2008: 7.</p>
      }

      expect(Taxon.count).to eq(10)

      subfamily = Subfamily.find_by_name 'Aneuretinae'
      expect(subfamily).not_to be_invalid
      expect(subfamily.type_name.to_s).to eq('Aneuretus')
      expect(subfamily.type_name.rank).to eq('genus')

      protonym = subfamily.protonym
      expect(protonym.name.to_s).to eq('Aneuretini')
      expect(protonym.name.rank).to eq('tribe')

      authorship = protonym.authorship
      expect(authorship.reference).to eq(emery)
      expect(authorship.pages).to eq('6')

      expect(subfamily.type_name.to_s).to eq('Aneuretus')
      expect(subfamily.type_name.rank).to eq('genus')

      expect(subfamily.history_items.map(&:taxt)).to match_array([
        "{nam #{Name.find_by_name('Aneuretinae').id}} as junior synonym of {nam #{Name.find_by_name('Dolichoderinae').id}}: {ref #{MissingReference.first.id}}: 147."
      ])

      tribe = Tribe.find_by_name 'Aneuretini'
      expect(tribe.subfamily).to eq(subfamily)
      expect(tribe.history_items.map(&:taxt)).to eq(["history"])
      expect(tribe.type_name.to_s).to eq('Aneuretus')
      expect(tribe.type_name.rank).to eq('genus')
      expect(tribe.reference_sections.map(&:title_taxt)).to eq(["Subfamily, tribe {tax #{Taxon.find_by_name('Aneuretini').id}} and genus {nam #{Name.find_by_name('Aneuretus').id}} references"])
      expect(tribe.reference_sections.map(&:references_taxt)).to eq(["{ref #{emery.id}}: 461 (diagnosis)"])

      junior_synonym = Tribe.find_by_name 'Anonychomyrmini'
      expect(junior_synonym).to be_synonym
      expect(junior_synonym).to be_synonym_of tribe

      aneuretus = Genus.find_by_name 'Aneuretus'
      expect(aneuretus.tribe).to eq(tribe)
      expect(aneuretus.subfamily).to eq(subfamily)
      expect(aneuretus.reference_sections.map(&:references_taxt)).to eq(["{tax #{aneuretus.id}} reference"])

      junior_synonym = Genus.find_by_name 'Odontomyrmex'
      expect(junior_synonym).to be_synonym_of aneuretus
      expect(junior_synonym).to be_synonym
      expect(junior_synonym.tribe).to eq(aneuretus.tribe)
      expect(junior_synonym.subfamily).to eq(aneuretus.subfamily)

      homonym = Genus.find_by_name 'Diabolus'
      expect(homonym).to be_homonym
      expect(homonym.homonym_replaced_by).to eq(junior_synonym)
      expect(homonym.tribe).to eq(aneuretus.tribe)
      expect(homonym.subfamily).to eq(aneuretus.subfamily)

      genus = Genus.find_by_name 'Burmomyrma'
      expect(genus).not_to be_invalid
      expect(genus).to be_fossil
      expect(genus.tribe).to be_nil
      expect(genus.incertae_sedis_in).to eq('subfamily')
      expect(genus.subfamily).to eq(subfamily)

      genus = Genus.find_by_name 'Wilsonia'
      expect(genus.tribe).to be_nil
      expect(genus.incertae_sedis_in).to eq('subfamily')
      expect(genus.subfamily).to eq(subfamily)
      expect(genus).to be_hong
      expect(genus.status).to eq(Status['valid'].to_s)

      collective_group_name = Genus.find_by_name 'Myrmeciites'
      expect(collective_group_name).to be_collective_group_name
    end
  end
end
