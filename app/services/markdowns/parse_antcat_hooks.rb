module Markdowns
  class ParseAntcatHooks
    include Rails.application.routes.url_helpers
    include ActionView::Helpers::UrlHelper
    include Service

    def initialize content
      @content = content
    end

    def call
      parse_taxon_ids!
      parse_reference_ids!
      parse_journal_ids!
      parse_issue_ids!
      parse_feedback_ids!
      parse_github_ids!
      parse_user_ids!

      content
    end

    private
      attr_reader :content

      # Matches: %taxon429349
      # Renders: link to the taxon (Formica).
      def parse_taxon_ids!
        content.gsub!(/%taxon(\d+)/) do
          try_linking_taxon_id $1
        end
      end

      # Matches: %reference130628
      # Renders: expandable referece as used in the catalog (Abdalla & Cruz-Landim, 2001).
      def parse_reference_ids!
        content.gsub!(/%reference?(\d+)/) do
          if Reference.exists? $1
            reference = Reference.find($1)
            reference.decorate.inline_citation
          else
            broken_markdown_link "reference", $1
          end
        end
      end

      # Matches: %journal123
      # Renders: link to the journal, with the journal's name as the title.
      def parse_journal_ids!
        content.gsub!(/%journal(\d+)/) do
          if Journal.exists? $1
            journal = Journal.find($1)
            link_to "<i>#{journal.name}</i>".html_safe, journal_path(journal)
          else
            broken_markdown_link "journal", $1
          end
        end
      end

      # Matches: %issue123
      # Renders: a link to the issue.
      def parse_issue_ids!
        content.gsub!(/%issue(\d+)/) do
          if Issue.exists? $1
            issue = Issue.find($1)
            link_to "issue ##{$1} (#{issue.title})", issue_path($1)
          else
            broken_markdown_link "issue", $1
          end
        end
      end

      # matches: %feedback123
      # Renders: a link to the feedback (including non-existing).
      def parse_feedback_ids!
        content.gsub!(/%feedback(\d+)/) do
          link_to "feedback ##{$1}", feedback_path($1)
        end
      end

      # Matches: %github123
      # renders: a link to the GitHub issue (including non-existing and PRs).
      def parse_github_ids!
        content.gsub!(/%github(\d+)/) do
          # Also works for PRs becuase GH figures that out.
          url = "https://github.com/calacademy-research/antcat/issues/#{$1}"
          link_to "GitHub ##{$1}", url
        end
      end

      # Matches: %user123
      # Renders: a link to the user's user page.
      def parse_user_ids!
        content.gsub!(/@user(\d+)/) do
          if User.exists? $1
            user = User.find($1)
            user.decorate.ping_user_link
          else
            broken_markdown_link "user", $1
          end
        end
      end

      # Very internal only.
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
end
