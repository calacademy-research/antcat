require "spec_helper"

describe Wikipedia::ReferenceExporter do
  let(:batiatus) do
    create :author_name, name: "Batiatus, Q. L.", author: build_stubbed(:author)
  end

  describe "ArticleReference" do
    let(:reference) do
      build_stubbed :article_reference,
        author_names: [batiatus], title: "*Formica* and Apples",
        pagination: "7-14", year: "2000", doi: "10.10.1038/nphys1170"
    end

    it "formats" do
      expect(described_class[reference]).to eq <<-TEMPLATE.squish
        <ref name="Batiatus_2000">{{cite journal
        |first1=Q. L. |last1=Batiatus |year=2000 |title=''Formica'' and Apples
        |url= |journal=#{reference.journal.name} |publisher= |volume=#{reference.volume} |issue=
        |pages=7–14 |doi=#{reference.doi} }}</ref>
      TEMPLATE
    end
  end

  describe "BookReference" do
    let(:reference) do
      glaber = create :author_name, name: "Glaber, G. C."
      create :book_reference,
        author_names: [batiatus, glaber], title: "*Formica* and Apples",
        pagination: "7-14", citation_year: "2000"
    end

    it "formats" do
      expect(described_class[reference]).to eq <<-TEMPLATE.squish
        <ref name="Batiatus_&_Glaber_2000">{{cite book
        |first1=Q. L. |last1=Batiatus |first2=G. C. |last2=Glaber
        |year=2000 |title=Formica and Apples |url=
        |location=San Francisco |publisher=Wiley
        |pages=7–14 |isbn=}}</ref>
      TEMPLATE
    end
  end

  describe "#reference_name" do
    it "handles single authors" do
      set_exporter_with_stubbed_reference "Batiatus"
      expect(@exporter.send(:reference_name)).to eq "Batiatus_2016"
    end

    it "handles two authors" do
      set_exporter_with_stubbed_reference "Batiatus", "Glaber"
      expect(@exporter.send(:reference_name)).to eq "Batiatus_&_Glaber_2016"
    end

    it "handles three authors" do
      set_exporter_with_stubbed_reference "Batiatus", "Glaber", "Varro"
      expect(@exporter.send(:reference_name)).to eq "Batiatus_et_al_2016"
    end
  end
end

def set_exporter_with_stubbed_reference *last_names
  allow_message_expectations_on_nil # TODO remove.
  expect(@reference).to receive(:author_names).
    and_return(last_names.map { |last_name| OpenStruct.new last_name: last_name })
  expect(@reference).to receive(:year).and_return "2016"
  @exporter = described_class.new @reference
end
