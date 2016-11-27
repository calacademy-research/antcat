# TODO move relevant examples (most) to `antcat_markdown_utils_spec.rb`.

require "spec_helper"

describe AntcatMarkdown do
  describe ".render" do
    it "formats some basic markdown" do
      lasius_name = create :species_name, name: "Lasius"
      create :species, name: lasius_name

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

      markdown = "%taxon#{lasius.id}"

      expect(AntcatMarkdown.render(markdown)).to eq <<-HTML
<p><a href="/catalog/#{lasius.id}"><i>Lasius</i></a></p>
      HTML
    end

    describe "reference ids" do
      context "existing reference" do
        it "links the reference" do
          reference = create :article_reference
          markdown = "%reference#{reference.id}"

          expected = "<p>#{reference.decorate.inline_citation}</p>\n"
          expect(AntcatMarkdown.render(markdown)).to eq expected
        end
      end

      context "missing (non-existing) reference" do
        it "renders an error message" do
          markdown = "%reference9999999"

          expected = %Q[<p><span class="broken-markdown-link"> could not find reference with id 9999999 </span></p>\n]
          expect(AntcatMarkdown.render(markdown)).to eq expected
        end
      end
    end

    describe "journal ids" do
      context "existing journal" do
        it "links the journal" do
          journal = create :journal, name: "Zootaxa"
          markdown = "%journal#{journal.id}"

          expected = %Q[<p><a href="/journals/#{journal.id}"><i>#{journal.name}</i></a></p>\n]
          expect(AntcatMarkdown.render(markdown)).to eq expected
        end
      end

      context "missing journal" do
        it "renders an error message" do
          markdown = "%journal9999999"

          expected = %Q[<p><span class="broken-markdown-link"> could not find journal with id 9999999 </span></p>\n]
          expect(AntcatMarkdown.render(markdown)).to eq expected
        end
      end
    end

    it "formats issue ids" do
      issue = create :issue
      markdown = "%issue#{issue.id}"

      expected = %Q[<p><a href="/issues/#{issue.id}">issue ##{issue.id} (Check synonyms)</a></p>\n]
      expect(AntcatMarkdown.render(markdown)).to eq expected
    end

    it "formats feedback ids" do
      feedback = create :feedback
      markdown = "%feedback#{feedback.id}"

      expected = %Q[<p><a href="/feedback/#{feedback.id}">feedback ##{feedback.id}</a></p>\n]
      expect(AntcatMarkdown.render(markdown)).to eq expected
    end

    it "formats GitHub links" do
      markdown = "%github5"

      expected = %Q[<p><a href="https://github.com/calacademy-research/antcat/issues/5">GitHub #5</a></p>\n]
      expect(AntcatMarkdown.render(markdown)).to eq expected
    end

    it "formats user links" do
      user = create :user
      markdown = "@user#{user.id}"

      results = AntcatMarkdown.render markdown
      expect(results).to include user.name
      expect(results).to include "users/#{user.id}"
    end
  end

  describe ".strip" do
    it "strips markdown" do
      expect(AntcatMarkdown.strip "**bold**").to eq "bold\n"
    end
  end
end
