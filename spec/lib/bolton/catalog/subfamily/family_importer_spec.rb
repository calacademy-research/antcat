# coding: UTF-8
require 'spec_helper'

describe Bolton::Catalog::Subfamily::Importer do

  it "should convert the HTML to an intermediate form and send it to Family.import" do
    html = %{
<html><body><div class=Section1>
<p><b>FAMILY FORMICIDAE</b></p>
<p><b>Family <span style='color:red'>FORMICIDAE</span> </b></p>
<p><b>Formicariae</b> Latreille, 1809: 124. Type-genus: <i>Formica</i>.</p>
<p><b>Taxonomic history</b></p>
<p>Formicidae as family: Latreille, 1809: 124 [Formicariae]; all subsequent authors. </p>
</div></body></html>
    }
    Family.should_receive(:import).with({
      :type => :family_group_headline,
      :family_or_subfamily_name => "Formicariae",
      :authorship => [
        {:author_names => ["Latreille"], :year=>"1809", :pages=>"124"}
      ],
      :type_genus => {:genus_name=>"Formica"}
    }, {
      :type => :family_taxonomic_history,
      :items => [
        {:author_names => ["Latreille"], :year => "1809", :pages => "124", :note => "[Formicariae]"},
        {:all_subsequent_authors => true}
      ]
    })
    Bolton::Catalog::Subfamily::Importer.new.import_html html
  end

end
