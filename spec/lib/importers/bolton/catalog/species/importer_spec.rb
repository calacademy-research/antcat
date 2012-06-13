# coding: UTF-8
require 'spec_helper'

describe Importers::Bolton::Catalog::Species::Importer do
  before do
    @importer = Importers::Bolton::Catalog::Species::Importer.new
  end

  it "should link species to existing genera" do
    contents = make_contents %{
<p><i>ACANTHOMYRMEX</i> (Oriental, Indo-Australian)</p>
<p><i>basispinosus</i>. <i>Acanthomyrmex basispinosus</i> Moffett, 1986c: 67, figs. 8A, 9-14 (s.w.) INDONESIA (Sulawesi). Combination in <i>Dorylus (Shuckardia)</i>: Emery, 1895j: 740.</p>
    }
    Progress.should_not_receive(:error)
    FactoryGirl.create :genus, name: FactoryGirl.create(:genus_name, name: 'Acanthomyrmex'), subfamily: nil, tribe: nil
    @importer.import_html contents

    Taxon.count.should == 2

    acanthomyrmex = Genus.find_by_name 'Acanthomyrmex'
    acanthomyrmex.should_not be_nil
    basispinosus = Species.find_by_name 'Acanthomyrmex basispinosus'
    basispinosus.genus.should == acanthomyrmex

    basispinosus.protonym.locality.should == 'Indonesia (Sulawesi)'
    basispinosus.protonym.authorship.forms.should == 's.w.'

    history = basispinosus.taxonomic_history_items
    history.size.should == 1
  end

  it "should link a synonym to its senior when the senior has already been seen" do
    contents = make_contents %{
<p><i>ACANTHOMYRMEX</i> (Oriental, Indo-Australian)</p>
<p><i>ferox</i>. <i>Acanthomyrmex ferox</i> Moffett, 1986c: 67 (s.w.) INDONESIA.</p>
<p><i>dyak</i>. <i>Acanthomyrmex dyak</i> Moffett, 1986c: 67 (s.w.) INDONESIA. Junior synonym of <i>ferox</i>: Moffett, 1986c: 70.</p>
    }
    FactoryGirl.create :genus, name: FactoryGirl.create(:genus_name, name: 'Acanthomyrmex'), subfamily: nil, tribe: nil
    @importer.import_html contents
    Species.find_by_name('Acanthomyrmex dyak').should be_synonym_of Species.find_by_name 'Acanthomyrmex ferox'
  end

  it "should link a synonym to its senior when the senior has not already been seen" do
    contents = make_contents %{
<p><i>ACANTHOMYRMEX</i> (Oriental, Indo-Australian)</p>
<p><i>dyak</i>. <i>Acanthomyrmex dyak</i> Moffett, 1986c: 67 (s.w.) INDONESIA. Junior synonym of <i>ferox</i>: Moffett, 1986c: 70.</p>
<p><i>ferox</i>. <i>Acanthomyrmex ferox</i> Moffett, 1986c: 67 (s.w.) INDONESIA.</p>
    }
    FactoryGirl.create :genus, name: FactoryGirl.create(:genus_name, name: 'Acanthomyrmex'), subfamily: nil, tribe: nil
    @importer.import_html contents
    Species.find_by_name('Acanthomyrmex dyak').should be_synonym_of Species.find_by_name 'Acanthomyrmex ferox'
  end

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
      @importer.parse_taxonomic_history([]).should == []
      @importer.parse_taxonomic_history(nil).should == []
    end

    it "should handle the happy case" do
      reference = FactoryGirl.create :article_reference, bolton_key_cache: 'Gray 1969'
      history = [{
        see_also: {references: [{author_names:['Gray'], year:'1969', pages:'94', matched_text:'Gray, 1969: 94'}]},
        matched_text: 'See also Gray, 1969: 94'
      }]
      @importer.parse_taxonomic_history(history).should == ["See also {ref #{reference.id}}: 94"]
    end

    it "should handle a single taxonomic history item that needs to be parsed as more than one taxt" do
      wheeler = FactoryGirl.create :article_reference, bolton_key_cache: 'Wheeler 1927h'
      emery = FactoryGirl.create :article_reference, bolton_key_cache: 'Emery 1915g'
      history = [{
        see_also: {},
        matched_text: 'Replacement name for <i>Acropyga silvestrii</i> Wheeler, W.M. 1927h: 100. [Junior primary homonym of <i>Acropyga silvestrii</i> Emery, 1915g: 21.]'
      }]
      history = @importer.parse_taxonomic_history history
      history.should == [
        "Replacement name for <i>Acropyga silvestrii</i> {ref #{wheeler.id}}: 100",
        "[Junior primary homonym of <i>Acropyga silvestrii</i> {ref #{emery.id}}: 21.]"
      ]
    end

    it "should handle forms with a reference" do
      reference = FactoryGirl.create :article_reference, bolton_key_cache: 'Mann 1916'
      @importer.parse_taxonomic_history([{
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
