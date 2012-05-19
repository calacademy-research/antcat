# coding: UTF-8
require 'spec_helper'

describe Importers::Bolton::Catalog::Species::DeepSpeciesImporter do
  before do
    @importer = Importers::Bolton::Catalog::Species::DeepSpeciesImporter.new
  end

  it "should link species to existing genera" do
    contents = make_contents %{
<p><i>ACANTHOMYRMEX</i> (Oriental, Indo-Australian)</p>
<p><i>basispinosus</i>. <i>Acanthomyrmex basispinosus</i> Moffett, 1986c: 67, figs. 8A, 9-14 (s.w.) INDONESIA (Sulawesi).</p>
    }
    Progress.should_not_receive(:error)
    FactoryGirl.create :genus, name: 'Acanthomyrmex', subfamily: nil, tribe: nil
    @importer.import_html contents

    Taxon.count.should == 2

    acanthomyrmex = Genus.find_by_name 'Acanthomyrmex'
    acanthomyrmex.should_not be_nil
    basispinosus = acanthomyrmex.species.find_by_name 'basispinosus'
    basispinosus.genus.should == acanthomyrmex

    basispinosus.protonym.locality.should == 'Indonesia (Sulawesi)'
    basispinosus.protonym.authorship.forms.should == 's.w.'
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

end
