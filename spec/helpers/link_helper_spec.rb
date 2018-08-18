require 'spec_helper'

describe LinkHelper do
  describe "#link_to_antwiki" do
    let(:taxon) { create :species }

    it "can link to species" do
      name = taxon.name_cache.tr(' ', '_')
      expect(helper.link_to_antwiki(taxon)).to eq(
        %(<a class="link_to_external_site" href="http://www.antwiki.org/wiki/#{name}">AntWiki</a>)
      )
    end
  end

  describe "#link_to_hol" do
    context "without a `#hol_id`" do
      let(:taxon) { build_stubbed :subfamily }

      it "doesn't link" do
        expect(helper.link_to_hol(taxon)).to be nil
      end
    end

    context "with a `#hol_id`" do
      let(:taxon) { build_stubbed :subfamily, hol_id: 1234 }

      it "links" do
        expect(helper.link_to_hol(taxon)).to eq(
          '<a class="link_to_external_site" href="http://hol.osu.edu/index.html?id=1234">HOL</a>'
        )
      end
    end
  end

  describe "#link_to_antweb" do
    it "handles subfamilies" do
      subfamily = create_subfamily 'Attaichnae'
      expect(helper.link_to_antweb(subfamily)).
        to eq '<a class="link_to_external_site" href="http://www.antweb.org/description.do?rank=subfamily&subfamily=attaichnae&project=worldants">AntWeb</a>'
    end

    it "outputs nothing for tribes" do
      tribe = create :tribe
      expect(helper.link_to_antweb(tribe)).to be_nil
    end

    it "handles genera" do
      genus = create_genus 'Atta'
      expect(helper.link_to_antweb(genus)).
        to eq '<a class="link_to_external_site" href="http://www.antweb.org/description.do?rank=genus&genus=atta&project=worldants">AntWeb</a>'
    end

    it "outputs nothing for subgenera" do
      subgenus = create_subgenus
      expect(helper.link_to_antweb(subgenus)).to be_nil
    end

    it "handles species" do
      species = create_species 'Atta major', genus: create_genus('Atta')
      expect(helper.link_to_antweb(species)).
        to eq '<a class="link_to_external_site" href="http://www.antweb.org/description.do?rank=species&genus=atta&species=major&project=worldants">AntWeb</a>'
    end

    it "handles subspecies" do
      genus = create_genus 'Atta'
      species = create_species 'Atta major', genus: genus
      subspecies = create_subspecies 'Atta major minor', species: species, genus: genus
      expect(helper.link_to_antweb(subspecies)).
        to eq '<a class="link_to_external_site" href="http://www.antweb.org/description.do?rank=subspecies&genus=atta&species=major&subspecies=minor&project=worldants">AntWeb</a>'
    end

    it "just returns nil for subspecies without species" do
      subspecies = create_subspecies 'Atta major minor', species: nil
      expect(helper.link_to_antweb(subspecies)).to be_nil
    end
  end
end
