require "spec_helper"

describe Wikipedia::ReferenceExporter do
  let(:batiatus) do
    build_stubbed :author_name, name: "Batiatus, Q. L.", author: build_stubbed(:author)
  end

  describe "ArticleReference" do
    before do
      journal = build_stubbed :journal, name: "Zootaxa"
      @reference = build_stubbed :article_reference, journal: journal,
        author_names: [batiatus], title: "*Formica* and Apples",
        pagination: "7-14", year: "2000"
    end

    it "formats" do
      exported = described_class.export @reference
      expect(exported).to eq <<-TEMPLATE.squish
        <ref name="Batiatus_2000">{{cite journal
        |first1=Q. L. |last1=Batiatus |year=2000 |title=''Formica'' and Apples
        |url= |journal=Zootaxa |publisher= |volume=#{@reference.volume} |issue=
        |pages=7–14 |doi=10.10.1038/nphys1170 }}</ref>
      TEMPLATE
    end
  end

  describe "BookReference" do
    before do
      glaber = build_stubbed :author_name,
        name: "Glaber, G. C.", author: build_stubbed(:author)
      @reference = build_stubbed :book_reference,
        author_names: [batiatus, glaber], title: "*Formica* and Apples",
        pagination: "7-14", year: "2000"
    end

    it "formats" do
      exported = described_class.export @reference
      expect(exported).to eq <<-TEMPLATE.squish
        <ref name="Batiatus_&_Glaber_2000">{{cite book
        |first1=Q. L. |last1=Batiatus |first2=G. C. |last2=Glaber
        |year=2000 |title=Formica and Apples |url=
        |location=New York |publisher=Wiley
        |pages=7–14 |isbn=}}</ref>
      TEMPLATE
    end
  end

  describe "#reference_name" do
    it "handles single authors" do
      set_exporter_with_stubbed_reference "Batiatus"
      expect(@exporter.send :reference_name).to eq "Batiatus_2016"
    end

    it "handles two authors" do
      set_exporter_with_stubbed_reference "Batiatus", "Glaber"
      expect(@exporter.send :reference_name).to eq "Batiatus_&_Glaber_2016"
    end

    it "handles three authors" do
      set_exporter_with_stubbed_reference "Batiatus", "Glaber", "Varro"
      expect(@exporter.send :reference_name).to eq "Batiatus_et_al_2016"
    end
  end
end

def set_exporter_with_stubbed_reference *last_names
  allow_message_expectations_on_nil
  @reference.stub(:author_names) do
    last_names.map do |last_name|
      OpenStruct.new last_name: last_name
    end
  end
  @reference.stub(:year) { "2016" }
  @exporter = described_class.new @reference
end
