require "spec_helper"

describe Markdowns::Render do
  describe "#call" do
    it "formats some basic markdown" do
      lasius_name = create :species_name, name: "Lasius"
      create :species, name: lasius_name

      markdown = <<-MARKDOWN
###Header
* A list item

*italics* **bold**
      MARKDOWN

      expect(described_class.new(markdown).call).to eq <<-HTML
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

      markdown = "%taxon#{lasius.id}"

      expect(described_class.new(markdown).call).to eq <<-HTML
<p><a href="/catalog/#{lasius.id}"><i>Lasius</i></a></p>
      HTML
    end

    describe "reference ids" do
      context "existing reference" do
        let(:reference) { create :article_reference }
        let(:markdown) { "%reference#{reference.id}" }

        it "links the reference" do
          expected = "<p>#{reference.decorate.inline_citation}</p>\n"
          expect(described_class.new(markdown).call).to eq expected
        end
      end

      context "missing (non-existing) reference" do
        let(:markdown) { "%reference9999999" }

        it "renders an error message" do
          expected = %Q[<p><span class="broken-markdown-link"> could not find reference with id 9999999 </span></p>\n]
          expect(described_class.new(markdown).call).to eq expected
        end
      end
    end

    describe "journal ids" do
      context "existing journal" do
        let(:journal) { create :journal, name: "Zootaxa" }
        let(:markdown) { "%journal#{journal.id}" }

        it "links the journal" do
          expected = %Q[<p><a href="/journals/#{journal.id}"><i>#{journal.name}</i></a></p>\n]
          expect(described_class.new(markdown).call).to eq expected
        end
      end

      context "missing journal" do
        let(:markdown) { "%journal9999999" }

        it "renders an error message" do
          expected = %Q[<p><span class="broken-markdown-link"> could not find journal with id 9999999 </span></p>\n]
          expect(described_class.new(markdown).call).to eq expected
        end
      end
    end

    it "formats issue ids" do
      issue = create :issue
      markdown = "%issue#{issue.id}"

      expected = %Q[<p><a href="/issues/#{issue.id}">issue ##{issue.id} (Check synonyms)</a></p>\n]
      expect(described_class.new(markdown).call).to eq expected
    end

    it "formats feedback ids" do
      feedback = create :feedback
      markdown = "%feedback#{feedback.id}"

      expected = %Q[<p><a href="/feedback/#{feedback.id}">feedback ##{feedback.id}</a></p>\n]
      expect(described_class.new(markdown).call).to eq expected
    end

    it "formats GitHub links" do
      markdown = "%github5"

      expected = %Q[<p><a href="https://github.com/calacademy-research/antcat/issues/5">GitHub #5</a></p>\n]
      expect(described_class.new(markdown).call).to eq expected
    end

    it "formats user links" do
      user = create :user
      markdown = "@user#{user.id}"

      results = described_class.new(markdown).call
      expect(results).to include user.name
      expect(results).to include "users/#{user.id}"
    end
  end
end
