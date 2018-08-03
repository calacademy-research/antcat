# The reason for supporting both "%taxon429349" and "{tax 429349}" is because the
# "%"-style is the original implementation, while the curly braces format is the
# original "taxt" format as used in taxt items.

module Markdowns
  class ParseAntcatHooks
    include Rails.application.routes.url_helpers
    include ActionView::Helpers::UrlHelper
    include Service

    def initialize content, include_search_history_links: false
      @content = content
      @include_search_history_links = include_search_history_links
    end

    def call
      parse_taxon_ids!
      parse_reference_ids!
      parse_name_ids!
      parse_journal_ids!
      parse_issue_ids!
      parse_feedback_ids!
      parse_github_ids!
      parse_user_ids!

      content
    end

    private

      attr_reader :content, :include_search_history_links

      # Matches: %taxon429349 and {tax 429349}
      # Renders: link to the taxon (Formica).
      def parse_taxon_ids!
        content.gsub!(/(%taxon(?<id>\d+))|(\{tax (?<id>\d+)\})/) do
          try_linking_taxon_id $~[:id]
        end
      end

      # Matches: %reference130628 and {ref 130628}
      # Renders: expandable referece as used in the catalog (Abdalla & Cruz-Landim, 2001).
      def parse_reference_ids!
        content.gsub!(/(%reference(?<id>\d+))|(\{ref (?<id>\d+)\})/) do
          id = $~[:id]
          begin
            reference = Reference.find(id)
            reference.decorate.expandable_reference
          rescue
            broken_markdown_link "reference", id
          end
        end
      end

      # Matches: {nam 134043}
      # Renders: HTML version of name (Formicidae).
      def parse_name_ids!
        content.gsub!(/(\{nam (?<id>\d+)\})/) do
          id = $~[:id]
          begin
            Name.find(id).to_html
          rescue
            broken_markdown_link "name", id
          end
        end
      end

      # Matches: %journal123
      # Renders: link to the journal, with the journal's name as the title.
      def parse_journal_ids!
        content.gsub!(/%journal(\d+)/) do
          begin
            journal = Journal.find($1)
            link_to "<i>#{journal.name}</i>".html_safe, journal_path(journal)
          rescue
            broken_markdown_link "journal", $1
          end
        end
      end

      # Matches: %issue123
      # Renders: a link to the issue.
      def parse_issue_ids!
        content.gsub!(/%issue(\d+)/) do
          begin
            issue = Issue.find($1)
            link_to "issue ##{$1} (#{issue.title})", issue_path($1)
          rescue
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
          begin
            user = User.find($1)
            user.decorate.ping_user_link
          rescue
            broken_markdown_link "user", $1
          end
        end
      end

      # Very internal only.
      def try_linking_taxon_id string
        taxon = Taxon.find(string)
        taxon.decorate.link_to_taxon
      rescue
        broken_markdown_link "taxon", string
      end

      def broken_markdown_link type, string
        if include_search_history_links
          broken_markdown_link_with_search_history_link type, string
        else
          broken_markdown_link_without_history_link type, string
        end
      end

      # TODO probably merge the "with" and "without" methods.
      def broken_markdown_link_without_history_link type, string
        <<-HTML.squish
          <span class="broken-markdown-link">
            could not find #{type} with id #{string}
          </span>
        HTML
      end

      def broken_markdown_link_with_search_history_link type, id
        <<-HTML.squish
          <span class="bold-warning">
            CANNOT FIND #{type.upcase} WITH ID #{id}#{seach_history_link(id)}
          </span>
        HTML
      end

      # TODO copy-pasted from `TaxtPresenter`.
      def seach_history_link id
        " " + link_to("Search history?", versions_path(item_id: id),
        class: "btn-normal btn-tiny")
      end
  end
end
