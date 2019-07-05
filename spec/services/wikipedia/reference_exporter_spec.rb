require "spec_helper"

describe Wikipedia::ReferenceExporter do
  let(:batiatus) { create :author_name, name: "Batiatus, Q. L." }
  let(:glaber) { create :author_name, name: "Glaber, G. C." }

  describe "when reference is an `ArticleReference`" do
    let(:reference) do
      build_stubbed :article_reference, :with_doi, author_names: [batiatus], title: "*Formica* and Apples",
        pagination: "7-14", year: "2000"
    end

    specify do
      expect(described_class[reference]).to eq <<-TEMPLATE.squish
        <ref name="Batiatus_2000">{{cite journal
        |first1=Q. L. |last1=Batiatus |year=2000 |title=''Formica'' and Apples
        |url= |journal=#{reference.journal.name} |publisher= |volume=#{reference.volume} |issue=
        |pages=7–14 |doi=#{reference.doi} }}</ref>
      TEMPLATE
    end
  end

  describe "when reference is a `BookReference`" do
    let(:reference) do
      build_stubbed :book_reference, author_names: [batiatus, glaber], title: "*Formica* and Apples",
        pagination: "7-14", year: "2000"
    end

    specify do
      expect(described_class[reference]).to eq <<-TEMPLATE.squish
        <ref name="Batiatus_&_Glaber_2000">{{cite book
        |first1=Q. L. |last1=Batiatus |first2=G. C. |last2=Glaber
        |year=2000 |title=Formica and Apples |url=
        |location=San Francisco |publisher=Wiley
        |pages=7–14 |isbn=}}</ref>
      TEMPLATE
    end
  end

  describe "name tag" do
    let(:reference) { build_stubbed :article_reference, author_names: author_names, year: "2016" }

    context "when reference has one author" do
      let(:author_names) { [batiatus] }

      specify { expect(described_class[reference]).to match 'name="Batiatus_2016"' }
    end

    context "when reference has two authors" do
      let(:author_names) { [batiatus, glaber] }

      specify { expect(described_class[reference]).to match 'name="Batiatus_&_Glaber_2016"' }
    end

    context "when reference has more than two authors" do
      let(:varro) { create :author_name, name: "Varro" }
      let(:author_names) { [batiatus, glaber, varro] }

      specify { expect(described_class[reference]).to match 'name="Batiatus_et_al_2016"' }
    end
  end
end
