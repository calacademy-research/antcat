require "spec_helper"

describe AntcatMarkdown do
  let(:dummy_parser) { AntcatMarkdown.new(no_even_a_stub: nil) }


  describe "render" do
    it "formats some basic markdown" do
      lasius_name = create :species_name, name: "Lasius"
      lasius = create :species, name: lasius_name
      markdown = <<-MARKDOWN
###Header
* A list item

*italics* **bold**
      MARKDOWN

      expect(AntcatMarkdown.render(markdown)).to eq <<-HTML
<h3>Header</h3>

<ul>
<li>A list item</li>
</ul>

<p><em>italics</em> <strong>bold</strong></p>
      HTML
    end

    it "formats taxon ids" do
      lasius_name = create :species_name, name: "Lasius"
      lasius = create :species, name: lasius_name

      markdown = "%#{lasius.id}"

      expect(AntcatMarkdown.render(markdown)).to eq <<-HTML
<p><a href="/catalog/#{lasius.id}"><i>Lasius</i></a></p>
      HTML
    end

    it "formats reference ids" do
      reference = create :article_reference
      markdown = "%r#{reference.id}"

      expected = "<p>#{reference.decorate.to_link}</p>\n"
      expect(AntcatMarkdown.render(markdown)).to eq expected
    end

    it "formats lists of taxon ids" do
      lasius_name = create :species_name, name: "Lasius"
      lasius = create :species, name: lasius_name

      markdown = "%tl[#{lasius.id}, #{lasius.id}]"

      expected = %Q[<p><a href="/catalog/#{lasius.id}"><i>Lasius</i></a>, ] +
                 %Q[<a href="/catalog/#{lasius.id}"><i>Lasius</i></a></p>\n]
      expect(AntcatMarkdown.render(markdown)).to eq expected
    end

    it "formats task ids" do
      task = create :task
      markdown = "%task#{task.id}"

      expected = %Q[<p><a href="/tasks/#{task.id}">task ##{task.id}</a></p>\n]
      expect(AntcatMarkdown.render(markdown)).to eq expected
    end

    it "formats feedback ids" do
      feedback = create :feedback
      markdown = "%feedback#{feedback.id}"

      expected = %Q[<p><a href="/feedback/#{feedback.id}">feedback ##{feedback.id}</a></p>\n]
      expect(AntcatMarkdown.render(markdown)).to eq expected
    end

    it "formats GitHub links" do
      markdown = "%github#{5}"

      expected = %Q[<p><a href="https://github.com/calacademy-research/antcat/issues/5">GitHub #5</a></p>\n]
      expect(AntcatMarkdown.render(markdown)).to eq expected
    end
  end

  describe "#try_linking_taxon_id" do
    it "return the string if there's no taxon" do
      returned = dummy_parser.send :try_linking_taxon_id, "9999"
      expect(returned).to eq "9999"
    end

    it "links existing taxa" do
      taxon = create :species
      returned = dummy_parser.send(:try_linking_taxon_id, taxon.id.to_s)

      expected = %Q[<a href="/catalog/#{taxon.id}"><i>#{taxon.name_cache}</i></a>]
      expect(returned).to eq expected
    end
  end
end