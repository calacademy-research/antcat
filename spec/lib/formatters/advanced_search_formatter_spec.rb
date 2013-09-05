# coding: UTF-8
require 'spec_helper'

class FormattersAdvancedSearchFormatterTestClass
  include Formatters::AdvancedSearchFormatter
end

describe Formatters::AdvancedSearchFormatter do
  before do
    @formatter = FormattersAdvancedSearchFormatterTestClass.new
  end

  #describe "Link creation" do
    #describe "link" do
      #it "should make a link to a new tab" do
        #@formatter.link('Atta', 'www.antcat.org/1', title: '1').should ==
          #%{<a href="www.antcat.org/1" target="_blank" title="1">Atta</a>}
      #end
      #it "should escape the name" do
        #@formatter.link('<script>', 'www.antcat.org/1', title: '1').should ==
          #%{<a href="www.antcat.org/1" target="_blank" title="1">&lt;script&gt;</a>}
      #end
    #end
    #describe "link_to_external_site" do
      #it "should make a link with the right class" do
        #@formatter.link_to_external_site('Atta', 'www.antcat.org/1').should ==
          #%{<a class="link_to_external_site" href="www.antcat.org/1" target="_blank">Atta</a>}
      #end
    #end
  #end

  #describe "Creating a link from another site to a taxon on AntCat" do
    #it "should create the link" do
      #genus = create_genus
      #@formatter.link_to_antcat(genus).should ==
        #%{<a class="link_to_external_site" href="http://www.antcat.org/catalog/#{genus.id}" target="_blank">AntCat</a>}
    #end
  #end

  #describe "Linking to AntWiki" do
    #it "should link to a subfamily" do
      #@formatter.link_to_antwiki(create_subfamily 'Dolichoderinae').should ==
        #%{<a class="link_to_external_site" href="http://www.antwiki.org/wiki/Dolichoderinae" target="_blank">AntWiki</a>}
    #end
    #it "should link to a species" do
      #@formatter.link_to_antwiki(create_species 'Atta major').should ==
        #%{<a class="link_to_external_site" href="http://www.antwiki.org/wiki/Atta_major" target="_blank">AntWiki</a>}
    #end
  #end

end

