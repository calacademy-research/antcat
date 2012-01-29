# coding: UTF-8
require 'spec_helper'

describe Bolton::Catalog::Subfamily::Importer do
  before do
    @importer = Bolton::Catalog::Subfamily::Importer.new
  end

  def make_contents contents
    @importer.stub :parse_family

    %{<html><body><div>
    <p>THE DOLICHODEROMORPHS: SUBFAMILIES ANEURETINAE AND DOLICHODERINAE</p>
    <p>SUBFAMILY MARTIALINAE</p>
    <p>Subfamily MARTIALINAE</p>
    <p>Martialinae Emery, 1913a: 6. Type-genus: <i>Aneuretus</i>.  </p>
    <p>Genus of Martialinae<span lang=EN-GB>: <i>Sphinctomyrmex</i>.</span></p>
    <p>Genus of Martialinae</p>
    <p>Genus <i>LASIUS</i></p>
    <p><i>Lasius</i> Mayr, 1866b: 895. Type-species: <i>Lasius stali</i>, by monotypy. </p>
    <p>Taxonomic history</p>
    <p>Lasius history</p>
    #{contents}
    </div></body></html>}
  end

  it "should work" do
    @importer.import_html make_contents %{
      <p>Subgenera of <i>LASIUS</i> include the nominal plus the following.</p>
      <p>Subgenus <i>LASIUS (ACANTHOMYOPS)</i></p>
      <p><i>Acanthomyops</i> Mayr, 1862: 652 (diagnosis in key), 699. Type-species: <i>Formica clavigera</i>, by monotypy. </p>
      <p>Taxonomic history</p>
      <p><i>Acanthomyops</i> in Formicinae: Mayr, 1862: 652 (in key) [Formicidae]; Mayr, 1865: 8 [Formicidae].</p>
    }
    lasius = Genus.find_by_name 'Lasius'

    acanthomyops = Subgenus.find_by_name 'Acanthomyops'
    acanthomyops.genus.should == lasius
    acanthomyops.type_taxon_name.should == 'Formica clavigera'

    lasius.subgenera.map(&:id).should == [acanthomyops.id]
  end

  it "should handle a homonym replaced by the subgenus" do
    @importer.import_html make_contents %{
      <p>Subgenera of <i>LASIUS</i> include the nominal plus the following.</p>
      <p>Subgenus <i>LASIUS (ACANTHOMYOPS)</i></p>
      <p><i>Acanthomyops</i> Mayr, 1862: 652 (diagnosis in key), 699. Type-species: <i>Formica clavigera</i>, by monotypy. </p>
      <p>Taxonomic history</p>
      <p><i>Acanthomyops</i> in Formicinae: Mayr, 1862: 652 (in key) [Formicidae]; Mayr, 1865: 8 [Formicidae].</p>

      <p>Homonym replaced by <i>ACANTHOMYOPS</i></p>
      <p><i>Orthonotus</i> Ashmead, 1905b: 384. Type-species: <i>Formica sericea</i>, by original designation.</p>
      <p>Taxonomic history</p>
      <p>Orthonotus history</p>
    }
    acanthomyops = Subgenus.find_by_name 'Acanthomyops'
    orthonotus = Subgenus.find_by_name 'Orthonotus'
    orthonotus.homonym_replaced_by.should == acanthomyops
    orthonotus.status.should == 'homonym'
  end

#<p>Junior synonyms of <i>STIGMACROS (MYAGROTERAS)</i></p>
#<p><i>Condylomyrma</i> Santschi, 1928c: 72 [as subgenus of <i>Camponotus</i>]. Type-species: <i>Camponotus (Condylomyrma) bryani</i>, by monotypy.</p>
#<p>Condylomyrma history</p>
end
