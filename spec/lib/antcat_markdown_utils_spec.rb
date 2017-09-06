require "spec_helper"

describe AntcatMarkdownUtils do
  let(:dummy) { described_class.new nil }

  describe ".users_mentioned_in" do
    let!(:batiatus) { create :user, name: "Batiatus"}
    let!(:joffre) { create :user, name: "Joffre"}

    it "returns existing mentioned users without duplicates" do
      expect(described_class.users_mentioned_in <<-STRING).to eq [batiatus, joffre]
        Hello @user#{batiatus.id}, @user#{joffre.id} and @user#{joffre.id}.
        Please call @user9999
      STRING
    end
  end

  describe "#try_linking_taxon_id" do
    context "existing taxon" do
      let!(:taxon) { create :species }

      it "links existing taxa" do
        expect(dummy.send :try_linking_taxon_id, taxon.id.to_s)
          .to eq %Q[<a href="/catalog/#{taxon.id}"><i>#{taxon.name_cache}</i></a>]
      end
    end

    context "missing taxon" do
      it "renders an error message" do
        expect(dummy.send :try_linking_taxon_id, "9999")
          .to eq '<span class="broken-markdown-link"> could not find taxon with id 9999 </span>'
      end
    end
  end
end
