require 'spec_helper'

describe LinkHelper do
  describe "Link creation" do
    describe "link" do
      it "should make a link to a new tab" do
        expect(helper.link('Atta', 'www.antcat.org/1', title: '1')).to eq(
          %{<a title="1" href="www.antcat.org/1">Atta</a>}
        )
      end
      it "should escape the name" do
        expect(helper.link('<script>', 'www.antcat.org/1', title: '1')).to eq(
          %{<a title="1" href="www.antcat.org/1">&lt;script&gt;</a>}
        )
      end
    end
    describe "link_to_external_site" do
      it "should make a link with the right class" do
        expect(helper.link_to_external_site('Atta', 'www.antcat.org/1')).to eq(
          %{<a class="link_to_external_site" target="_blank" href="www.antcat.org/1">Atta</a>}
        )
      end
    end
  end

  describe "Creating a link from another site to a taxon on AntCat" do
    it "should create the link" do
      genus = create_genus
      expect(helper.link_to_antcat(genus)).to eq(
        %{<a class="link_to_external_site" target="_blank" href="http://www.antcat.org/catalog/#{genus.id}">AntCat</a>}
      )
    end
  end

  describe "Linking to AntWiki" do
    it "should link to a subfamily" do
      expect(helper.link_to_antwiki(create_subfamily 'Dolichoderinae')).to eq(
        %{<a class="link_to_external_site" target="_blank" href="http://www.antwiki.org/wiki/Dolichoderinae">AntWiki</a>}
      )
    end
    it "should link to a species" do
      expect(helper.link_to_antwiki(create_species 'Atta major')).to eq(
        %{<a class="link_to_external_site" target="_blank" href="http://www.antwiki.org/wiki/Atta_major">AntWiki</a>}
      )
    end
  end

  describe "Linking to HOL" do
    it "should provide no link if there's no matching hol_data" do
      expect(helper.link_to_hol(create_subfamily 'Dolichoderinae')).to be nil
    end

    # we have one valid entry
    it "should provide a link if there's a valid hol_data entry" do
      taxon = create_subfamily 'Dolichoderinae'
      FactoryGirl.create :hol_taxon_datum, antcat_taxon_id: taxon.id, tnuid: 1234
      expect(helper.link_to_hol(taxon)).to eq (
        %{<a class=\"link_to_external_site\" target=\"_blank\" href=\"http://hol.osu.edu/index.html?id=1234\">HOL</a>}
                                                  )
    end

    # we have one invalid entry
    it "should provide a link if there's one invalid hol_data entry" do
      taxon = create_subfamily 'Dolichoderinae'
      FactoryGirl.create :hol_taxon_datum, antcat_taxon_id: taxon.id, tnuid: 1234, is_valid: 'Invalid'
      expect(helper.link_to_hol(taxon)).to eq (
        %{<a class=\"link_to_external_site\" target=\"_blank\" href=\"http://hol.osu.edu/index.html?id=1234\">HOL</a>}
                                                  )
    end

    # we have one valid entry and one invalid entry

    it "should provide a link if there's one valid and one invalid hol_data entry" do
      taxon = create_subfamily 'Dolichoderinae'
      FactoryGirl.create :hol_taxon_datum, antcat_taxon_id: taxon.id, tnuid: 1234
      FactoryGirl.create :hol_taxon_datum, antcat_taxon_id: taxon.id, tnuid: 1235, is_valid: 'Invalid'
      expect(helper.link_to_hol(taxon)).to eq (
             %{<a class=\"link_to_external_site\" target=\"_blank\" href=\"http://hol.osu.edu/index.html?id=1234\">HOL</a>})
    end

    it "should provide no link if there are two invalid entries" do
      taxon = create_subfamily 'Dolichoderinae'
      FactoryGirl.create :hol_taxon_datum, antcat_taxon_id: taxon.id, tnuid: 1234, is_valid: 'Invalid'
      FactoryGirl.create :hol_taxon_datum, antcat_taxon_id: taxon.id, tnuid: 1235, is_valid: 'Invalid'
      expect(helper.link_to_hol(create_subfamily 'Dolichoderinae')).to be nil
    end

    it "should provide no link if there are two valid entries" do
      taxon = create_subfamily 'Dolichoderinae'
      FactoryGirl.create :hol_taxon_datum, antcat_taxon_id: taxon.id, tnuid: 1234, is_valid: 'Valid'
      FactoryGirl.create :hol_taxon_datum, antcat_taxon_id: taxon.id, tnuid: 1235, is_valid: 'Valid'
      expect(helper.link_to_hol(create_subfamily 'Dolichoderinae')).to be nil
    end
  end

  describe "Creating a link from a site to AntWeb" do
    it "should handle subfamilies" do
      subfamily = create_subfamily 'Attaichnae'
      expect(helper.link_to_antweb(subfamily)).to eq("<a class=\"link_to_external_site\" target=\"_blank\" href=\"http://www.antweb.org/description.do?rank=subfamily&subfamily=attaichnae&project=worldants\">AntWeb</a>")
    end
    it "should output nothing for tribes" do
      tribe = create_tribe 'Attini'
      expect(helper.link_to_antweb(tribe)).to be_nil
    end
    it "should handle genera" do
      genus = create_genus 'Atta'
      expect(helper.link_to_antweb(genus)).to eq("<a class=\"link_to_external_site\" target=\"_blank\" href=\"http://www.antweb.org/description.do?rank=genus&genus=atta&project=worldants\">AntWeb</a>")
    end
    it "should output nothing for subgenera" do
      genus = create_genus 'Atta'
      subgenus = create_subgenus 'Atta (Batta)', genus: genus
      expect(helper.link_to_antweb(subgenus)).to be_nil
    end
    it "should handle species" do
      genus = create_genus 'Atta'
      species = create_species 'Atta major', genus: genus
      expect(helper.link_to_antweb(species)).to eq("<a class=\"link_to_external_site\" target=\"_blank\" href=\"http://www.antweb.org/description.do?rank=species&genus=atta&species=major&project=worldants\">AntWeb</a>")
    end
    it "should handle subspecies" do
      genus = create_genus 'Atta'
      species = create_species 'Atta major', genus: genus
      subspecies = create_subspecies 'Atta major minor', species: species, genus: genus
      expect(helper.link_to_antweb(subspecies)).to eq("<a class=\"link_to_external_site\" target=\"_blank\" href=\"http://www.antweb.org/description.do?rank=subspecies&genus=atta&species=major&subspecies=minor&project=worldants\">AntWeb</a>")
    end
    it "should just return nil for subspecies without species" do
      subspecies = create_subspecies 'Atta major minor', species: nil
      expect(helper.link_to_antweb(subspecies)).to be_nil
    end
    it "should handle quadrinomial subspecies", pending: true do
      pending "are there any valid quadrinomials?"
      genus = create_genus 'Atta'
      species = create_species 'Atta major', genus: genus
      subspecies = create_subspecies 'Atta major minor rufous', species: species, genus: genus
      expect(helper.link_to_antweb(subspecies)).to eq("<a class=\"link_to_external_site\" target=\"_blank\" href=\"http://www.antweb.org/description.do?rank=subspecies&genus=atta&species=major&subspecies=minor rufous&project=worldants\">AntWeb</a>")
    end
  end
end
