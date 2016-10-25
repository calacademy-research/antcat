# Probably GitHub markdown (?) with some custom tags.
require "redcarpet/render_strip"

class AntcatMarkdown < Redcarpet::Render::HTML
  include Rails.application.routes.url_helpers
  include ActionView::Helpers::UrlHelper

  def self.render text
    options = {
      hard_wrap: true,
      space_after_headers: true,
      fenced_code_blocks: true,
      underline: false,
    }

    extensions = {
      autolink: true,
      superscript: true,
      disable_indented_code_blocks: true,
      tables: true,
      underline: false,
      no_intra_emphasis: true,
    }

    renderer = AntcatMarkdown.new options
    markdowner = Redcarpet::Markdown.new renderer, extensions

    markdowner.render(text).html_safe
  end

  def self.strip text
    rendered = Redcarpet::Render::StripDown
    markdowner = Redcarpet::Markdown.new rendered
    markdowner.render text
  end

  def preprocess full_document
    # TODO make smarter
    parsed = parse_taxon_ids full_document
    parsed = parse_reference_ids parsed
    parsed = parse_journal_ids parsed
    parsed = parse_taxon_ids_list parsed
    parsed = parse_task_ids parsed
    parsed = parse_feedback_ids parsed
    parsed = parse_github_ids parsed
    parsed
  end

  private
    # matches: %t429349
    # renders: link to the taxon (Formica)
    def parse_taxon_ids full_document
      full_document.gsub(/%t(\d+)/) do
        try_linking_taxon_id $1
      end
    end

    # matches: %r130628
    # renders: referece as used in the catalog (Abdalla & Cruz-Landim, 2001)
    def parse_reference_ids full_document
      full_document.gsub(/%r(\d+)/) do
        if Reference.exists? $1
          reference = Reference.find($1)
          reference.decorate.to_link
        else
          broken_markdown_link "reference", $1
        end
      end
    end

    # matches: %j123
    # renders: link to the journal, with the journal's name as the title
    def parse_journal_ids full_document
      full_document.gsub(/%j(\d+)/) do
        if Journal.exists? $1
          journal = Journal.find($1)
          link_to journal.name, journal_path(journal)
        else
          broken_markdown_link "journal", $1
        end
      end
    end

    # matches: %tl[497190, 497191, 497192]
    # renders: links to the taxa, separated by comma
    def parse_taxon_ids_list full_document
      full_document.gsub(/%tl\[(.*?)\]/) do
        ids_string = $1
        ids = ids_string.gsub(" ", "").split(",")

        ids.map do |id|
          try_linking_taxon_id id
        end.join(", ")
      end
    end

    # matches: %task123
    # renders: a link to the task (including non-existing)
    def parse_task_ids full_document
      full_document.gsub(/%task(\d+)/) do
        link_to "task ##{$1}", task_path($1)
      end
    end

    # matches: %feedback123
    # renders: a link to the feedback (including non-existing)
    def parse_feedback_ids full_document
      full_document.gsub(/%feedback(\d+)/) do
        link_to "feedback ##{$1}", feedback_path($1)
      end
    end

    # matches: %github123
    # renders: a link to the GitHub issue (including non-existing and PRs)
    def parse_github_ids full_document
      full_document.gsub(/%github(\d+)/) do
        # Also works for PRs becuase GH figures that out.
        url = "https://github.com/calacademy-research/antcat/issues/#{$1}"
        link_to "GitHub ##{$1}", url
      end
    end

    # internal only
    def try_linking_taxon_id string
      if Taxon.exists? string
        taxon = Taxon.find(string)
        taxon.decorate.link_to_taxon
      else
        broken_markdown_link "taxon", string
      end
    end

    def broken_markdown_link type, string
      <<-HTML.squish
        <span class="broken-markdown-link">
          could not find #{type} with id #{string}
        </span>
      HTML
    end
end
