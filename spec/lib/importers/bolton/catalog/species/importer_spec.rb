# coding: UTF-8
require 'spec_helper'

describe Importers::Bolton::Catalog::Species::Importer do
  before do
    @importer = Importers::Bolton::Catalog::Species::Importer.new
  end

  describe "Importing subspecies" do
    it "should work" do
      genus = create_genus 'Camponotus'
      subgenus = create_subgenus 'Camponotus (Myrmeurynota)'

      @importer.import_html make_contents %{
        <p><i>CAMPONOTUS</i></p>
        <p><i>gilviventris</i>. <i>Camponotus gilviventris</i> Roger, 1863a: 145 (w.) CUBA.
        <p><i>refectus</i>. <i>Camponotus (Myrmeurynota) gilviventris</i> var. <i>refectus</i> Wheeler, W.M. 1937b: 460 (w.) CUBA.</p>
      }
      @importer.finish_importing
      subspecies = Subspecies.find_by_name 'Camponotus (Myrmeurynota) gilviventris refectus'
      subspecies.genus.name.to_s.should == 'Camponotus'
      subspecies.species.name.to_s.should == 'Camponotus gilviventris'
    end
  end

  it "should link species to existing genera" do
    contents = make_contents %{
      <p><i>ACANTHOMYRMEX</i> (Oriental, Indo-Australian)</p>
      <p><i>basispinosus</i>. <i>Acanthomyrmex basispinosus</i> Moffett, 1986c: 67, figs. 8A, 9-14 (s.w.) INDONESIA (Sulawesi).</p>
    }
    Progress.should_not_receive(:error)
    create_genus 'Acanthomyrmex', subfamily: nil, tribe: nil
    @importer.import_html contents

    Taxon.count.should == 2

    acanthomyrmex = Genus.find_by_name 'Acanthomyrmex'
    acanthomyrmex.should_not be_nil
    basispinosus = Species.find_by_name 'Acanthomyrmex basispinosus'
    basispinosus.genus.should == acanthomyrmex

    basispinosus.protonym.locality.should == 'Indonesia (Sulawesi)'
    basispinosus.protonym.authorship.forms.should == 's.w.'
  end

  it "should link a synonym to its senior when the senior has already been seen" do
    create_genus 'Acanthomyrmex'
    contents = make_contents %{
      <p><i>ACANTHOMYRMEX</i></p>
      <p><i>ferox</i>. <i>Acanthomyrmex ferox</i> Moffett, 1986c: 67.w.) INDONESIA.</p>
      <p><i>dyak</i>. <i>Acanthomyrmex dyak</i> Moffett, 1986c: 67.w.) INDONESIA. Junior synonym of <i>ferox</i>: Moffett, 1986c: 70.</p>
    }
    @importer.import_html contents
    @importer.finish_importing
    dyak = Species.find_by_name 'Acanthomyrmex dyak'
    ferox = Species.find_by_name 'Acanthomyrmex ferox'
    dyak.should be_synonym_of ferox
  end

  it "should handle a genus header note" do
    create_genus 'Crematogaster'
    contents = make_contents %{
      <p><i>CREMATOGASTER</i></p>
      <p>[Notes.]
    }
    @importer.import_html contents
    @importer.finish_importing
    Genus.find_by_name('Crematogaster').genus_species_header_note.should == '[Notes.]'
  end

  it "should convert the {nam}s in taxt to {tax}s" do
    Importers::Bolton::Catalog::TextToTaxt.should_receive :replace_names_with_taxa
    @importer.finish_importing
  end

  it "should handle this" do
    create_genus 'Camponotus'
    contents = make_contents %{
      <p><i>CAMPONOTUS</i></p>
      <p><i>ferox</i>. <i>Acanthomyrmex ferox</i> Moffett, 1986c: 67.w.) INDONESIA.</p>
      <p><i>macrocephalus</i>. <i>Camponotus macrocephalus</i> Emery, 1894c: 169 (s.) BRAZIL. [Junior secondary homonym of <i>macrocephala</i> Erichson, above.] Emery, 1920c: 36 (q.). Combination in <i>C. (Myrmamblys)</i>: Forel, 1912i: 90; in <i>C. (Pseudocolobopsis)</i>: Emery, 1920b: 259. Senior synonym of <i>geralensis</i>, <i>luederwaldti</i>: Kempf, 1968b: 408. <i>C. geralensis</i> first available replacement name for <i>macrocephalus</i> Emery: Shattuck & McArthur, 1995: 122.</p>
    }
    @importer.import_html contents
    @importer.finish_importing
    Species.find_by_name('Camponotus macrocephalus').should be_homonym
  end

  it "should link a synonym to its senior when the senior has not already been seen" do
    create_genus 'Acanthomyrmex', subfamily: nil, tribe: nil
    contents = make_contents %{
      <p><i>ACANTHOMYRMEX</i> (Oriental, Indo-Australian)</p>
      <p><i>dyak</i>. <i>Acanthomyrmex dyak</i> Moffett, 1986c: 67 (s.w.) INDONESIA. Junior synonym of <i>ferox</i>: Moffett, 1986c: 70.</p>
      <p><i>ferox</i>. <i>Acanthomyrmex ferox</i> Moffett, 1986c: 67 (s.w.) INDONESIA.</p>
    }
    @importer.import_html contents
    Species.find_by_name('Acanthomyrmex dyak').should be_synonym_of Species.find_by_name 'Acanthomyrmex ferox'
  end

  it "should pick the valid genus when there's two" do
    genus = create_genus 'Acanthomyrmex', status: 'synonym'
    valid = create_genus name: genus.name, status: 'valid'
    contents = make_contents %{
      <p><i>ACANTHOMYRMEX</i></p>
      <p><i>dyak</i>. <i>Acanthomyrmex dyak</i> Moffett, 1986c: 67 (s.w.) INDONESIA. Junior synonym of <i>ferox</i>: Moffett, 1986c: 70.</p>
    }
    @importer.import_html contents
    Species.find_by_name('Acanthomyrmex dyak').genus.should == valid
  end

  #it "should recognize a homonym and link to it" do
    #create_genus 'Acropyga', subfamily: nil, tribe: nil
    #contents = make_contents %{
      #<p><i>ACROPYGA</i></p>
      #<p><i>silvestrii</i>. <i>Acropyga (Rhizomyrma) silvestrii</i> Wheeler, W.M. 1927h: 100. [Junior primary homonym of <i>silvestrii</i> Emery, below.] Replacement name: <i>indosinensis</i> Wheeler, W.M. 1935c: 72.
      #<p><i>silvestrii</i>. <i>Acropyga silvestrii</i> Emery, 1915g: 21. 11 (w.) ETHIOPIA.</p>
#</p>    }
    #@importer.import_html contents
    #junior_homonym = Taxon.find_by_name 'Acropyga silvestrii'
    #senior_homonym = Taxon.find_by_name 'Acropyga silvestrii'
    #junior_homonym.homonym_replaced_by?(senior_homonym).should be
  #end

  def make_contents content
    %{
      <html> <head> <title>CATALOGUE OF SPECIES-GROUP TAXA</title> </head>
      <body>
      <div class=Section1>
      <p><b>CATALOGUE OF SPECIES-GROUP TAXA<o:p></o:p></b></p>
      <p><o:p>&nbsp;</o:p></p>
      <p><o:p>&nbsp;</o:p></p>
            #{content}
      <p><o:p>&nbsp;</o:p></p>
      </div> </body> </html>
    }
  end

  describe "Parsing taxonomic history" do

    it "should handle nothing" do
      @importer.class.convert_history_to_taxts([]).should == []
      @importer.class.convert_history_to_taxts(nil).should == []
    end

    it "should handle the happy case" do
      reference = FactoryGirl.create :article_reference, bolton_key_cache: 'Gray 1969'
      history = [{
        see_also: {references: [{author_names:['Gray'], year:'1969', pages:'94', matched_text:'Gray, 1969: 94'}]},
        matched_text: 'See also Gray, 1969: 94'
      }]
      @importer.class.convert_history_to_taxts(history).should == ["See also {ref #{reference.id}}: 94"]
    end

    it "should handle a single taxonomic history item that needs to be parsed as more than one taxt" do
      wheeler = FactoryGirl.create :article_reference, bolton_key_cache: 'Wheeler 1927h'
      emery = FactoryGirl.create :article_reference, bolton_key_cache: 'Emery 1915g'
      history = [{
        see_also: {},
        matched_text: 'Replacement name for <i>Acropyga silvestrii</i> Wheeler, W.M. 1927h: 100. [Junior primary homonym of <i>Acropyga silvestrii</i> Emery, 1915g: 21.]'
      }]
      history = @importer.class.convert_history_to_taxts history
      history.should == [
        "Replacement name for {nam #{Name.find_by_name('Acropyga silvestrii').id}} {ref #{wheeler.id}}: 100",
        "[Junior primary homonym of {nam #{Name.find_by_name('Acropyga silvestrii').id}} {ref #{emery.id}}: 21.]"
      ]
    end

    it "should handle Combination in..." do
      history = [{matched_text: "Combination in"}]
      history = @importer.class.convert_history_to_taxts history
      history.should == ["Combination in"]
    end

    it "should handle forms with a reference" do
      reference = FactoryGirl.create :article_reference, bolton_key_cache: 'Mann 1916'
      @importer.class.convert_history_to_taxts([{
        references: [{
          author_names: ['Mann'], year: '1916', pages: '452', forms: 'q',
          matched_text: 'Mann, 1916: 452 (q)'
        }],
        matched_text: 'Mann, 1916: 452 (q).'
      }]).should == [
        "{ref #{reference.id}}: 452 (q)"
      ]
    end
  end

end
