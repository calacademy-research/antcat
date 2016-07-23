require 'spec_helper'

describe LinkHelper do
  describe "link creation" do
    describe "#link" do
      it "makes a link to a new tab" do
        expect(helper.link('Atta', 'www.antcat.org/1', title: '1'))
          .to eq %{<a title="1" href="www.antcat.org/1">Atta</a>}
      end

      it "escapes the name" do
        expect(helper.link('<script>', 'www.antcat.org/1', title: '1'))
          .to eq %{<a title="1" href="www.antcat.org/1">&lt;script&gt;</a>}
      end
    end

    describe "#link_to_external_site" do
      it "makes a link with the right class" do
        expect(helper.link_to_external_site('Atta', 'www.antcat.org/1'))
          .to eq %{<a class="link_to_external_site" target="_blank" href="www.antcat.org/1">Atta</a>}
      end
    end
  end

  # Creating a link from another site to a taxon on AntCat
  describe "#link_to_antcat" do
    it "creates the link" do
      genus = create_genus
      expect(helper.link_to_antcat(genus)).to eq(
        %{<a class="link_to_external_site" target="_blank" href="http://www.antcat.org/catalog/#{genus.id}">AntCat</a>}
      )
    end
  end

  describe "#link_to_antwiki" do
    it "can link subfamilies" do
      expect(helper.link_to_antwiki(create_subfamily 'Dolichoderinae')).to eq(
        %{<a class="link_to_external_site" target="_blank" href="http://www.antwiki.org/wiki/Dolichoderinae">AntWiki</a>}
      )
    end

    it "can link to species" do
      expect(helper.link_to_antwiki(create_species 'Atta major')).to eq(
        %{<a class="link_to_external_site" target="_blank" href="http://www.antwiki.org/wiki/Atta_major">AntWiki</a>}
      )
    end
  end

  describe "#link_to_hol" do
    #ZZZ
    context "without a #hol_id" do
    it "doesn't link" do
      expect(helper.link_to_hol(create_subfamily 'Dolichoderinae')).to be nil
    end
    end

    context "with a #hol_id" do
    it "links" do
      taxon = create_subfamily 'Dolichoderinae'
      taxon.hol_id = 1234
      taxon.save!

      expect(helper.link_to_hol(taxon)).to eq(
        %{<a class=\"link_to_external_site\" target=\"_blank\" href=\"http://hol.osu.edu/index.html?id=1234\">HOL</a>})
    end
    end
  end

  describe "creating a link from a site to AntWeb" do
    it "handles subfamilies" do
      subfamily = create_subfamily 'Attaichnae'
      expect(helper.link_to_antweb(subfamily))
        .to eq "<a class=\"link_to_external_site\" target=\"_blank\" href=\"http://www.antweb.org/description.do?rank=subfamily&subfamily=attaichnae&project=worldants\">AntWeb</a>"
    end

    it "outputs nothing for tribes" do
      tribe = create_tribe 'Attini'
      expect(helper.link_to_antweb(tribe)).to be_nil
    end

    it "handles genera" do
      genus = create_genus 'Atta'
      expect(helper.link_to_antweb(genus))
        .to eq "<a class=\"link_to_external_site\" target=\"_blank\" href=\"http://www.antweb.org/description.do?rank=genus&genus=atta&project=worldants\">AntWeb</a>"
    end

    it "outputs nothing for subgenera" do
      genus = create_genus 'Atta'
      subgenus = create_subgenus 'Atta (Batta)', genus: genus
      expect(helper.link_to_antweb(subgenus)).to be_nil
    end

    it "handles species" do
      genus = create_genus 'Atta'
      species = create_species 'Atta major', genus: genus
      expect(helper.link_to_antweb(species))
        .to eq "<a class=\"link_to_external_site\" target=\"_blank\" href=\"http://www.antweb.org/description.do?rank=species&genus=atta&species=major&project=worldants\">AntWeb</a>"
    end

    it "handles subspecies" do
      genus = create_genus 'Atta'
      species = create_species 'Atta major', genus: genus
      subspecies = create_subspecies 'Atta major minor', species: species, genus: genus
      expect(helper.link_to_antweb(subspecies))
        .to eq "<a class=\"link_to_external_site\" target=\"_blank\" href=\"http://www.antweb.org/description.do?rank=subspecies&genus=atta&species=major&subspecies=minor&project=worldants\">AntWeb</a>"
    end

    it "just returns nil for subspecies without species" do
      subspecies = create_subspecies 'Atta major minor', species: nil
      expect(helper.link_to_antweb(subspecies)).to be_nil
    end

    it "handles quadrinomial subspecies", pending: true do
      pending "are there any valid quadrinomials?"
      genus = create_genus 'Atta'
      species = create_species 'Atta major', genus: genus
      subspecies = create_subspecies 'Atta major minor rufous', species: species, genus: genus
      expect(helper.link_to_antweb(subspecies))
        .to eq "<a class=\"link_to_external_site\" target=\"_blank\" href=\"http://www.antweb.org/description.do?rank=subspecies&genus=atta&species=major&subspecies=minor rufous&project=worldants\">AntWeb</a>"
    end
  end

  describe "#taxon_link_or_deleted_string" do
    context "valid taxon" do
      it "links" do
        genus = create_genus "Atta"
        expect(helper.taxon_link_or_deleted_string genus.id).to match /a href.*?Atta/
      end
    end

    context "without a valid taxon" do
      it "returns the id and more" do
        expect(helper.taxon_link_or_deleted_string 99999).to eq "#99999 [deleted]"
      end

      it "allows custom deleted_label" do
        expect(helper.taxon_link_or_deleted_string 99999, "deleted").to eq "deleted"
      end
    end
  end
end
