# TODO: Move most specs here to `parse_antcat_hooks_spec.rb`.

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

      expect(described_class[markdown]).to eq <<-HTML
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

      expect(described_class[markdown]).to eq <<-HTML
<p><a href="/catalog/#{lasius.id}"><i>Lasius</i></a></p>
      HTML
    end

    describe "reference ids" do
      context "existing reference" do
        let(:reference) { create :article_reference }
        let(:markdown) { "%reference#{reference.id}" }
        let(:taxt_markdown) { "{ref #{reference.id}}" }

        it "links the reference" do
          expected = "<p>#{reference.decorate.inline_citation}</p>\n"
          expect(described_class[markdown]).to eq expected
          expect(described_class[taxt_markdown]).to eq expected
        end
      end

      context "missing (non-existing) reference" do
        let(:markdown) { "%reference9999999" }
        let(:taxt_markdown) { '{ref 9999999}' }

        it "renders an error message" do
          expected = %(<p><span class="broken-markdown-link"> could not find reference with id 9999999 </span></p>\n)
          expect(described_class[markdown]).to eq expected
          expect(described_class[taxt_markdown]).to eq expected
        end
      end
    end

    describe "name ids" do
      context "existing name" do
        let(:name) { create :genus_name }
        let(:taxt_markdown) { "{nam #{name.id}}" }

        it "render the HTML version of the name" do
          expected = "<p><i>#{name}</i></p>\n"
          expect(described_class[taxt_markdown]).to eq expected
        end
      end

      context "missing (non-existing) name" do
        let(:taxt_markdown) { '{nam 9999999}' }

        it "renders an error message" do
          expected = %(<p><span class="broken-markdown-link"> could not find name with id 9999999 </span></p>\n)
          expect(described_class[taxt_markdown]).to eq expected
        end
      end
    end

    describe "journal ids" do
      context "existing journal" do
        let(:journal) { create :journal, name: "Zootaxa" }
        let(:markdown) { "%journal#{journal.id}" }

        it "links the journal" do
          expected = %(<p><a href="/journals/#{journal.id}"><i>#{journal.name}</i></a></p>\n)
          expect(described_class[markdown]).to eq expected
        end
      end

      context "missing journal" do
        let(:markdown) { "%journal9999999" }

        it "renders an error message" do
          expected = %(<p><span class="broken-markdown-link"> could not find journal with id 9999999 </span></p>\n)
          expect(described_class[markdown]).to eq expected
        end
      end
    end

    it "formats issue ids" do
      issue = create :issue
      markdown = "%issue#{issue.id}"

      expected = %[<p><a href="/issues/#{issue.id}">issue ##{issue.id} (Check synonyms)</a></p>\n]
      expect(described_class[markdown]).to eq expected
    end

    it "formats feedback ids" do
      feedback = create :feedback
      markdown = "%feedback#{feedback.id}"

      expected = %(<p><a href="/feedback/#{feedback.id}">feedback ##{feedback.id}</a></p>\n)
      expect(described_class[markdown]).to eq expected
    end

    it "formats GitHub links" do
      markdown = "%github5"

      expected = %(<p><a href="https://github.com/calacademy-research/antcat/issues/5">GitHub #5</a></p>\n)
      expect(described_class[markdown]).to eq expected
    end

    it "formats user links" do
      user = create :user
      markdown = "@user#{user.id}"

      results = described_class[markdown]
      expect(results).to include user.name
      expect(results).to include "users/#{user.id}"
    end
  end
end
