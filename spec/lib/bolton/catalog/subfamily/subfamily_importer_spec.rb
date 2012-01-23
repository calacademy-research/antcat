# coding: UTF-8
require 'spec_helper'

describe Bolton::Catalog::Subfamily::Importer do
  before do
    @importer = Bolton::Catalog::Subfamily::Importer.new
  end

  describe "Importing HTML" do

    before do
      Factory :article_reference, :author_names => [Factory(:author_name, :name => 'Latreille, I.')], :citation_year => '1809', :title => 'Ants', :bolton_key_cache => 'Latreille 1809'
      Family.import( 
        :protonym => {
          :family_or_subfamily_name => "Formicariae",
          :authorship => [{:author_names => ["Latreille"], :year => "1809", :pages => "124"}],
        },
        :type_genus => {:genus_name => 'Formica'},
        :taxonomic_history => ['Taxonomic history']
      )
      ForwardReference.fixup
      @importer.stub :parse_family
    end

    def make_contents content
      %{<html><body><div><p>THE DOLICHODEROMORPHS: SUBFAMILIES ANEURETINAE AND DOLICHODERINAE<o:p></p>#{content}</div></body></html>}
    end

    it "should import a subfamily" do
      emery = Factory :article_reference, bolton_key_cache: 'Emery 1913a'
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

      }

      Taxon.count.should == 3

      subfamily = Subfamily.find_by_name 'Aneuretinae'
      subfamily.should_not be_invalid
      subfamily.type_taxon_name.should == 'Aneuretus'

      protonym = subfamily.protonym
      protonym.name.should == 'Aneuretini'
      protonym.rank.should == 'tribe'

      authorship = protonym.authorship
      authorship.reference.should == emery
      authorship.pages.should == '6'

      type_taxon = subfamily.type_taxon
      type_taxon.name.should == 'Aneuretus'
      type_taxon.subfamily.should == subfamily

      subfamily.taxonomic_history_items.map(&:taxt).should =~ [
        "Aneuretinae as junior synonym of Dolichoderinae: {ref #{MissingReference.first.id}}: 147"
      ]

    end
  end

#<p>Tribe ANEURETINI</p>
#<p>Aneuretini Emery, 1913a: 6. Type-genus: <i>Aneuretus</i>.</p>
#<p>Taxonomic history</p>
#<p>Aneuretini as tribe of Dolichoderinae: Emery, 1913a: 6; Wheeler, W.M. 1915h: 71; Forel, 1917: 247; Wheeler, W.M. 1922a: 687; Carpenter, 1930: 37; Chapman &amp; Capco, 1951: 181; Brown, 1954e: 29 (in text).</p>
#<p>Genera (extant) of Aneuretini: <i>Aneuretus</i>, <i>Aneuretellus</i>.</p>

#<p>Subfamily, tribe Aneuretini and genus <i>Aneuretus</i> references</p>
#<p>Forel, 1895e: 461 (diagnosis).</p>

#<p>Genera of Aneuretini</p>

#<p>Genus <i>ANEURETELLUS</i></p>
#<p><i>Aneuretellus</i> Dlussky, 1988: 54. Type-species: *<i>Aneuretellus deformis</i>, by original designation.</p>
#<p>Taxonomic history</p>
#<p>[<i>Aneuretellus</i> also described as new by Emery, 1893f: 241.]</p>
#<p>Genus *<i>Aneuretellus</i> references</p>
#<p>[Note. Entries prior to Bolton, 1995b: 44, refer to genus as <i>Acantholepis</i>.]</p>

#<p>Genus <i>ANEURETUS</i></p>
#<p><i>Aneuretus</i> Emery, 1893a: cclxxv. Type-species: <i>Aneuretus simoni</i>, by monotypy.</p>
#<p>Taxonomic history</p>
#<p>[<i>Aneuretus</i> also described as new by Emery, 1893f: 241.]</p>
#<p>Genus references: see under Aneuretini, above.</p>

#<p>Tribes (extinct) <i>incertae sedis</i> in ANEURETINAE</p>
#<p>Tribe MIOMYRMECINI</p>
#<p>Miomyrmecini Emery, 1913a: 6. Type-genus: <i>Murmetus</i>.</p>
#<p>Taxonomic history</p>
#<p>[Bracketed note]</p>

#<p>Genera of Hong (2002), <i>incertae sedis</i> in ANEURETINAE</p>
      #}
#<p>Junior synonyms of <i>ANEURETUS</i></p>
#<p><i>Odontomyrmex</i> André, 1905: 207. Type-species: <i>Odontomyrmex quadridentatus</i>, by monotypy. </p>
#<p>Odontomyrmex history</p>

#<p>Tribe PITYOMYRMECINI<o:p></o:p></p>
#<p>Pityomyrmecini Emery, 1913a: 6. Type-genus: <i>Aneuretus</i>.</p>
#<p>Pityomyrmecini history</p>

#<p>Genera <i>incertae sedis</i> in ANEURETINAE</p>

#<p>Genus *<i>BURMOMYRMA</i></p>
#<p><i>Burmomyrma</i></p>
#<p>Burmomyrma history</p>

#<p>Junior synonyms of <i>BURMOMYRMA</i></p>

#<p>*<i>Burmomoma</i> Scudder, 1877b: 270 [as member of family Braconidae]. Type-species: *<i>Calyptites antediluvianum</i>, by monotypy. </p>

#<p>Homonym replaced by <i>Burmomoma</i></p>
#<p><i>Decamera</i> Roger, 1863a: 166. Type-species: <i>Decamera nigella</i>, by monotypy. </p>
#<p>Decamera history</p>

#<p>SUBFAMILY DOLICHODERINAE</p>

#<p>Subfamily DOLICHODERINAE</p>
#<p>Dolichoderinae Emery, 1913a: 6. Type-genus: <i>Aneuretus</i>.</p>
#<p>Dolichoderinae history</p>
#<p>Genera (extant) of Dolichoderinae: <i>Stigmacros</i>.</p>

#<p>Genera of Dolichoderinae</p>

#<p>Genus <i>STIGMACROS</i></p>
#<p><i>Stigmacros</i> Forel, 1905b: 179 [as subgenus of <i>Acantholepis</i>].</p>

#<p>Homonym replaced by <i>STIGMACROS</i></p>
#<p><i>Acrostigma</i> Forel, 1902h: 477 [as subgenus of <i>Acantholepis</i>].  Type-species: <i>Acantholepis (Acrostigma) froggatti</i>, by subsequent designation of Wheeler, W.M. 1911f: 158. </p>

#<p>Subgenera of <i>STIGMACROS</i> include the nominal plus the following.</p>
#<p>Subgenera note</p>
#<p>Subgenus <i>STIGMACROS (MYAGROTERAS)</i></p>
#<p><i>Myagroteras</i> Moffett, 1985b: 31 [as subgenus of <i>Myrmoteras</i>].  Type-species: <i>Myrmoteras donisthorpei</i>, by original designation.</p>

#<p>Junior synonyms of <i>STIGMACROS (MYAGROTERAS)</i></p>
#<p><i>Condylomyrma</i> Santschi, 1928c: 72 [as subgenus of <i>Camponotus</i>]. Type-species: <i>Camponotus (Condylomyrma) bryani</i>, by monotypy.</p>
#<p>Condylomyrma history</p>

#<p>Subgenus <i>CAMPONOTUS (ORTHONOTOMYRMEX)</i></p>
#<p><i>Orthonotomyrmex</i> Ashmead, 1906: 31.</p>
#<p>Orthonotomyrmex history></p>

#<p>Homonym replaced by <i>ORTHONOTOMYRMEX</i></p>
#<p><i>Orthonotus</i> Ashmead, 1905b: 384. Type-species: <i>Formica sericea</i>, by original designation.</p>
#<p>Orthonotus history</p>
#<p>THE FORMICOMORPHS: SUBFAMILY FORMICINAE</p>

#<p>SUBFAMILY FORMICINAE</p>
#<p>Subfamily FORMICINAE</p>
#<p>Formicinae Emery, 1913a: 6. Type-genus: <i>Aneuretus</i>.</p>
#<p>Formicinae history</p>
      #}

      #aneuretinae = Subfamily.find_by_name 'Aneuretinae'
      #aneuretinae.taxonomic_history.should ==
#'<p><b>Aneuretini</b> Emery, 1913a: 6. Type-genus: <i>Aneuretus</i>.  </p>' +
#'<p>Aneuritinae history</p>' +
#'<p><b>Tribes of Aneuretinae</b>: Aneuretini, *Pityomyrmecini.</p>' +
#'<p><b>Tribes <i>incertae sedis</i> in Aneuretinae</b>: *Miomyrmecini.</p>' +
#'<p><b>Genera (extinct) <i>incertae sedis</i> in Aneuretinae</b>: *<i>Burmomyrma, *Cananeuretus</i>. </p>' +
#'<p><b>Genus <i>incertae sedis</i> in Aneuretinae</b>: <i>Wildensis</i>. </p>' +
#'<p><b>Hong (2002) genera (extinct) <i>incertae sedis</i> in Aneuretinae</b>: *<i>Curtipalpulus, *Eoleptocerites</i> (unresolved junior homonym).</p>' +
#'<p><b>Collective group name in Myrmeciinae</b>: *<i>Myrmeciites</i>.</p>' +
#'<p>References</p>' +
#'<p>a references</p>'

      #aneuretini = Tribe.find_by_name 'Aneuretini'
      #aneuretini.subfamily.should == aneuretinae
      #aneuretini.should_not be_fossil
      #aneuretini.taxonomic_history.should ==
#%{<p><b>Aneuretini</b> Emery, 1913a: 6. Type-genus: <i>Aneuretus</i>.  </p>} +
#%{<p>Aneuretini history</p>} +
#%{<p><b>Genus (extant) of Aneuretini</b>: <i>Aneuretus</i>.</p>} +
#%{<p><b>Junior synonym of ANEURETINI<p></p></b></p>} +
#%{<p><b>Stictoponerini</b> Arnol'di, 1930d: 161. Type-genus: <i>Stictoponera</i> (junior synonym of <i>Gnamptogenys</i>).</p>} +
#%{<p><b>Taxonomic history<p></p></b></p>} +
#%{<p>Stictoponerini as subtribe of Aneuretini: Arnol'di, 1930d: 161.</p>}

      #stictoponerini = Tribe.find_by_name 'Stictoponerini'
      #stictoponerini.should_not be_fossil
      #stictoponerini.should be_invalid
      #stictoponerini.status.should == 'synonym'
      #stictoponerini.synonym_of.should == aneuretini

      #taxon = Tribe.find_by_name 'Pityomyrmecini'
      #taxon.subfamily.should == aneuretinae
      #taxon.should be_fossil
      #taxon.taxonomic_history.should ==
#%{<p><b>Pityomyrmecini</b> Emery, 1913a: 6. Type-genus: <i>Aneuretus</i>.  </p>} +
#%{<p>Pityomyrmecini history</p>}
      #taxon = Tribe.find_by_name 'Miomyrmecini'
      #taxon.subfamily.should == aneuretinae
      #taxon.incertae_sedis_in.should == 'subfamily'

      #burmomyrma = Genus.find_by_name 'Burmomyrma'
      #burmomyrma.subfamily.should == aneuretinae
      #burmomyrma.should be_fossil
      #burmomyrma.incertae_sedis_in.should == 'subfamily'
      #burmomyrma.should_not be_invalid
      #burmomyrma.taxonomic_history.should == 
#%{<p><b><i>Burmomyrma</i></b></p><p>Burmomyrma history</p>} +
#%{<p><b>Junior synonyms of <i>BURMOMYRMA<p></p></i></b></p>} +
#%{<p>*<b><i>Burmomoma</i></b> Scudder, 1877b: 270 [as member of family Braconidae]. Type-species: *<i>Calyptites antediluvianum</i>, by monotypy. </p>} +
#%{<p><b>Homonym replaced by <i>Burmomoma</i></b><p></p></p>} +
#%{<p><b><i>Decamera</i></b> Roger, 1863a: 166. Type-species: <i>Decamera nigella</i>, by monotypy. </p>} +
#%{<p><b>Decamera history<p></p></b></p>}

      #burmomoma = Genus.find_by_name 'Burmomoma'
      #burmomoma.should be_fossil
      #burmomoma.should be_invalid
      #burmomoma.status.should == 'synonym'
      #burmomoma.synonym_of.should == burmomyrma

      #taxon = Genus.find_by_name 'Cananeuretus'
      #taxon.subfamily.should == aneuretinae
      #taxon.should be_fossil
      #taxon.incertae_sedis_in.should == 'subfamily'
      #taxon.should_not be_invalid

      #taxon = Genus.find_by_name 'Wildensis'
      #taxon.subfamily.should == aneuretinae
      #taxon.should_not be_fossil
      #taxon.incertae_sedis_in.should == 'subfamily'
      #taxon.should_not be_invalid

      #taxon = Genus.find_by_name 'Curtipalpulus'
      #taxon.subfamily.should == aneuretinae
      #taxon.should be_fossil
      #taxon.incertae_sedis_in.should == 'subfamily'
      #taxon.should_not be_invalid

      #taxon = Genus.find_by_name 'Eoleptocerites'
      #taxon.subfamily.should == aneuretinae
      #taxon.should be_fossil
      #taxon.incertae_sedis_in.should == 'subfamily'
      #taxon.status.should == 'unresolved homonym'

      #taxon = Genus.find_by_name 'Myrmeciites'
      #taxon.should be_nil

      #aneuretus = Genus.find_by_name 'Aneuretus'
      #aneuretus.subfamily.should == aneuretinae
      #aneuretus.tribe.should == aneuretini
      #aneuretus.should_not be_fossil
      #aneuretus.should_not be_invalid
      #aneuretus.taxonomic_history.should ==
#%{<p><b><i>Aneuretus</i></b></p>} +
#%{<p>Aneuretus history</p>} +
#%{<p><b>Junior synonyms of <i>ANEURETUS<p></p></i></b></p>} +
#%{<p><b><i>Odontomyrmex</i></b> André, 1905: 207. Type-species: <i>Odontomyrmex quadridentatus</i>, by monotypy. </p>} +
#%{<p>Odontomyrmex history</p>}

      #odontomyrmex = Genus.find_by_name 'Odontomyrmex'
      #odontomyrmex.subfamily.should == aneuretinae
      #odontomyrmex.tribe.should == aneuretini
      #odontomyrmex.should be_invalid
      #odontomyrmex.taxonomic_history.should == 
#%{<p><b><i>Odontomyrmex</i></b> André, 1905: 207. Type-species: <i>Odontomyrmex quadridentatus</i>, by monotypy. </p>} +
#%{<p>Odontomyrmex history</p>}
      #odontomyrmex.status.should == 'synonym'
      #odontomyrmex.synonym_of.should == aneuretus

      #dolichoderinae = Subfamily.find_by_name 'Dolichoderinae'
      #dolichoderinae.should_not be_invalid
      #dolichoderinae.taxonomic_history.should == 
#'<p><b>Dolichoderinae</b> Emery, 1913a: 6. Type-genus: <i>Aneuretus</i>.  </p>' +
#%{<p>Dolichoderinae history</p>} +
#%{<p><b>Genera (extant) of Dolichoderinae</b>: <i>Stigmacros</i>.</p>}
      #taxon = Subfamily.find_by_name 'Formicinae'
      #taxon.should_not be_invalid
      #taxon.taxonomic_history.should ==
#%{<p><b>Formicinae</b> Emery, 1913a: 6. Type-genus: <i>Aneuretus</i>.  </p>} +
#%{<p>Formicinae history</p>}

      #stigmacros = Genus.find_by_name 'Stigmacros'
      #stigmacros.should_not be_nil
      #stigmacros.subgenera.map(&:name).should =~ ['Myagroteras', 'Condylomyrma', 'Orthonotomyrmex']
      #stigmacros.taxonomic_history.should ==
#%{<p><b><i>Stigmacros</i></b> Forel, 1905b: 179 [as subgenus of <i>Acantholepis</i>].  </p>} +

#%{<p><b>Subgenera of <i>STIGMACROS</i> include the nominal plus the following.<p></p></b></p>} +
#%{<p>Subgenera note</p>} +
#%{<p><b>Subgenus <i>STIGMACROS (MYAGROTERAS)</i> <p></p></b></p>} +
#%{<p><b><i>Myagroteras</i></b> Moffett, 1985b: 31 [as subgenus of <i>Myrmoteras</i>].  Type-species: <i>Myrmoteras donisthorpei</i>, by original designation.</p>} +
#%{<p><b>Junior synonyms of <i>STIGMACROS (MYAGROTERAS)</i></b><p></p></p>} +
#%{<p><b><i>Condylomyrma</i></b> Santschi, 1928c: 72 [as subgenus of <i>Camponotus</i>].  Type-species: <i>Camponotus (Condylomyrma) bryani</i>, by monotypy. </p>} +
#%{<p><b>Condylomyrma history<p></p></b></p>} +
#%{<p><b>Subgenus <i>CAMPONOTUS (ORTHONOTOMYRMEX)</i> <p></p></b></p>} +
#%{<p><b><i>Orthonotomyrmex</i></b> Ashmead, 1906: 31.</p>} +
#%{<p><b>Orthonotomyrmex history<p></p></b></p>} +
#%{<p><b>Homonym replaced by <i>ORTHONOTOMYRMEX</i> <p></p></b></p>} +
#%{<p><b><i>Orthonotus</i></b> Ashmead, 1905b: 384. Type-species: <i>Formica sericea</i>, by original designation. </p>} +
#%{<p>Orthonotus history</p>}

      #acrostigma = Genus.find_by_name 'Acrostigma'
      #acrostigma.should be_homonym_replaced_by stigmacros

      #myagroteras = Subgenus.find_by_name 'Myagroteras'
      #myagroteras.genus.should == stigmacros
      #myagroteras.taxonomic_history.should ==
#%{<p><b><i>Myagroteras</i></b> Moffett, 1985b: 31 [as subgenus of <i>Myrmoteras</i>].  Type-species: <i>Myrmoteras donisthorpei</i>, by original designation.</p>} +
#%{<p><b>Junior synonyms of <i>STIGMACROS (MYAGROTERAS)</i></b><p></p></p>} +
#%{<p><b><i>Condylomyrma</i></b> Santschi, 1928c: 72 [as subgenus of <i>Camponotus</i>].  Type-species: <i>Camponotus (Condylomyrma) bryani</i>, by monotypy. </p>} +
#%{<p><b>Condylomyrma history<p></p></b></p>}

      #condylomyrma = Subgenus.find_by_name 'Condylomyrma'
      #condylomyrma.genus.should == stigmacros
      #condylomyrma.status.should == 'synonym'
      #condylomyrma.synonym_of.should == myagroteras
      #condylomyrma.taxonomic_history.should == 
#%{<p><b><i>Condylomyrma</i></b> Santschi, 1928c: 72 [as subgenus of <i>Camponotus</i>].  Type-species: <i>Camponotus (Condylomyrma) bryani</i>, by monotypy. </p>} +
#%{<p><b>Condylomyrma history<p></p></b></p>}

      #orthonotomyrmex = Subgenus.find_by_name 'Orthonotomyrmex'
      #orthonotomyrmex.genus.should == stigmacros
      #orthonotomyrmex.taxonomic_history.should == 
#%{<p><b><i>Orthonotomyrmex</i></b> Ashmead, 1906: 31.</p>} +
#%{<p><b>Orthonotomyrmex history<p></p></b></p>} +
#%{<p><b>Homonym replaced by <i>ORTHONOTOMYRMEX</i> <p></p></b></p>} +
#%{<p><b><i>Orthonotus</i></b> Ashmead, 1905b: 384. Type-species: <i>Formica sericea</i>, by original designation. </p>} +
#%{<p>Orthonotus history</p>}

      #orthonotus = Subgenus.find_by_name 'Orthonotus'
      #orthonotus.should be_nil
    #end

end

