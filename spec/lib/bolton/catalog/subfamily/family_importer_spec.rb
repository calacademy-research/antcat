# coding: UTF-8
require 'spec_helper'

describe Bolton::Catalog::Subfamily::Importer do

  it "should convert the HTML to an intermediate form and send it to Family.import" do
    Factory :article_reference, :bolton_key_cache => 'Latreille 1809'
    html = %{
<html><body><div class=Section1>
<p><b>FAMILY FORMICIDAE</b></p>
<p><b>Family <span style='color:red'>FORMICIDAE</span> </b></p>
<p><b>Formicariae</b> Latreille, 1809: 124. Type-genus: <i>Formica</i>.</p>
<p><b>Taxonomic history</b></p>
<p>Formicidae as family: Latreille, 1809: 124 [Formicariae]; all subsequent authors. </p>
</div></body></html>
    }
    data =  {
      :protonym => {
        :name => "Formicariae",
        :authorship => [{:author_names => ["Latreille"], :year => "1809", :pages => "124"}],
      },
      :type_genus => 'Formica'
    }

    Bolton::Catalog::Subfamily::Importer.new.import_html html

    family = Family.first
    family.type_taxon.name.should == 'Formica'
  end

end
