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

    describe "reference ids" do
      context "existing reference" do
        it "links the reference" do
          reference = create :article_reference
          markdown = "%r#{reference.id}"

          expected = "<p>#{reference.decorate.to_link}</p>\n"
          expect(AntcatMarkdown.render(markdown)).to eq expected
        end
      end

      context "missing (non-existing) reference" do
        it "renders an error message" do
          markdown = "%r9999999"

          expected = %Q[<p><span class="broken-markdown-link"> could not find reference with id 9999999 </span></p>\n]
          expect(AntcatMarkdown.render(markdown)).to eq expected
        end
      end
    end

    describe "journal ids" do
      context "existing journal" do
        it "links the journal" do
          journal = create :journal, name: "Zootaxa"
          markdown = "%j#{journal.id}"

          expected = %Q[<p><a href="/journals/#{journal.id}">#{journal.name}</a></p>\n]
          expect(AntcatMarkdown.render(markdown)).to eq expected
        end
      end

      context "missing journal" do
        it "renders an error message" do
          markdown = "%j9999999"

          expected = %Q[<p><span class="broken-markdown-link"> could not find journal with id 9999999 </span></p>\n]
          expect(AntcatMarkdown.render(markdown)).to eq expected
        end
      end
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
    context "existing taxon" do
      it "links existing taxa" do
        taxon = create :species
        returned = dummy_parser.send(:try_linking_taxon_id, taxon.id.to_s)

        expected = %Q[<a href="/catalog/#{taxon.id}"><i>#{taxon.name_cache}</i></a>]
        expect(returned).to eq expected
      end
    end

    context "missing taxon" do
      it "renders an error message" do
        returned = dummy_parser.send :try_linking_taxon_id, "9999"
        expect(returned).to eq '<span class="broken-markdown-link"> could not find taxon with id 9999 </span>'
      end
    end
  end
end
