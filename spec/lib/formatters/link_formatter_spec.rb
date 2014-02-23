# coding: UTF-8
require 'spec_helper'

class FormattersLinkFormatterTestClass
  include Formatters::LinkFormatter
end

describe Formatters::LinkFormatter do
  before do
    @formatter = FormattersLinkFormatterTestClass.new
  end

  describe "Link creation" do
    describe "link" do
      it "should make a link to a new tab" do
        @formatter.link('Atta', 'www.antcat.org/1', title: '1').should ==
          %{<a href="www.antcat.org/1" target="_blank" title="1">Atta</a>}
      end
      it "should escape the name" do
        @formatter.link('<script>', 'www.antcat.org/1', title: '1').should ==
          %{<a href="www.antcat.org/1" target="_blank" title="1">&lt;script&gt;</a>}
      end
    end
    describe "link_to_external_site" do
      it "should make a link with the right class" do
        @formatter.link_to_external_site('Atta', 'www.antcat.org/1').should ==
          %{<a class="link_to_external_site" href="www.antcat.org/1" target="_blank">Atta</a>}
      end
    end
  end

  describe "Creating a link from another site to a taxon on AntCat" do
    it "should create the link" do
      genus = create_genus
      @formatter.link_to_antcat(genus).should ==
        %{<a class="link_to_external_site" href="http://www.antcat.org/catalog/#{genus.id}" target="_blank">AntCat</a>}
    end
  end

  describe "Linking to AntWiki" do
    it "should link to a subfamily" do
      @formatter.link_to_antwiki(create_subfamily 'Dolichoderinae').should ==
        %{<a class="link_to_external_site" href="http://www.antwiki.org/wiki/Dolichoderinae" target="_blank">AntWiki</a>}
    end
    it "should link to a species" do
      @formatter.link_to_antwiki(create_species 'Atta major').should ==
        %{<a class="link_to_external_site" href="http://www.antwiki.org/wiki/Atta_major" target="_blank">AntWiki</a>}
    end
  end

  describe "Creating a link from a site to AntWeb" do
    it "should handle subfamilies" do
      subfamily = create_subfamily 'Attaichnae'
      @formatter.link_to_antweb(subfamily).should == "<a class=\"link_to_external_site\" href=\"http://www.antweb.org/description.do?rank=subfamily&subfamily=attaichnae&project=worldants\" target=\"_blank\">AntWeb</a>"
    end
    it "should output nothing for tribes" do
      tribe = create_tribe 'Attini'
      @formatter.link_to_antweb(tribe).should be_nil
    end
    it "should handle genera" do
      genus = create_genus 'Atta'
      @formatter.link_to_antweb(genus).should == "<a class=\"link_to_external_site\" href=\"http://www.antweb.org/description.do?rank=genus&genus=atta&project=worldants\" target=\"_blank\">AntWeb</a>"
    end
    it "should output nothing for subgenera" do
      genus = create_genus 'Atta'
      subgenus = create_subgenus 'Atta (Batta)', genus: genus
      @formatter.link_to_antweb(subgenus).should be_nil
    end
    it "should handle species" do
      genus = create_genus 'Atta'
      species = create_species 'Atta major', genus: genus
      @formatter.link_to_antweb(species).should == "<a class=\"link_to_external_site\" href=\"http://www.antweb.org/description.do?rank=species&genus=atta&species=major&project=worldants\" target=\"_blank\">AntWeb</a>"
    end
    it "should handle subspecies" do
      genus = create_genus 'Atta'
      species = create_species 'Atta major', genus: genus
      subspecies = create_subspecies 'Atta major minor', species: species, genus: genus
      @formatter.link_to_antweb(subspecies).should == "<a class=\"link_to_external_site\" href=\"http://www.antweb.org/description.do?rank=subspecies&genus=atta&species=major&subspecies=minor&project=worldants\" target=\"_blank\">AntWeb</a>"
    end
    it "should just return nil for subspecies without species" do
      subspecies = create_subspecies 'Atta major minor', species: nil
      @formatter.link_to_antweb(subspecies).should be_nil
    end
    it "should handle quadrinomial subspecies" do
      genus = create_genus 'Atta'
      species = create_species 'Atta major', genus: genus
      subspecies = create_subspecies 'Atta major minor rufous', species: species, genus: genus
      @formatter.link_to_antweb(subspecies).should == "<a class=\"link_to_external_site\" href=\"http://www.antweb.org/description.do?rank=subspecies&genus=atta&species=major&subspecies=minor rufous&project=worldants\" target=\"_blank\">AntWeb</a>"
    end
  end
end
