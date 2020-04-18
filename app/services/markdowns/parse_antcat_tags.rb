# frozen_string_literal: true

require 'English'

module Markdowns
  class ParseAntcatTags
    include Rails.application.routes.url_helpers
    include ActionView::Helpers::UrlHelper
    include ActionView::Helpers::SanitizeHelper
    include Service

    USER_TAG_REGEX = /@user(?<id>\d+)/
    GITHUB_TAG_REGEX = /%github(?<issue_id>\d+)/
    WIKI_TAG_REGEX = /%wiki(?<id>\d+)/
    DB_SCRIPT_TAG_REGEX = /%dbscript:(?<basename>[A-Z][A-Za-z0-9_]+)/

    def initialize content, sanitize_content: true
      @content = sanitize_content ? sanitize(content).to_str : content
    end

    def call
      parse_github_tags
      parse_wiki_tags
      parse_user_tags
      parse_dbscript_tags

      content
    end

    private

      attr_reader :content

      # Matches: %github123
      # renders: a link to the GitHub issue (including non-existing and PRs).
      def parse_github_tags
        content.gsub!(GITHUB_TAG_REGEX) do
          # Also works for PRs because GH figures that out.
          github_issue_id = $LAST_MATCH_INFO[:issue_id]
          url = "https://github.com/calacademy-research/antcat/issues/#{github_issue_id}"
          link_to "GitHub ##{github_issue_id}", url
        end
      end

      # Matches: %wiki123
      # Renders: a link to the wiki page.
      def parse_wiki_tags
        content.gsub!(WIKI_TAG_REGEX) do
          wiki_page_id = $LAST_MATCH_INFO[:id]

          begin
            wiki_page = WikiPage.find(wiki_page_id)
            link_to wiki_page.title, wiki_page_path(wiki_page_id)
          rescue ActiveRecord::RecordNotFound
            broken_markdown_link "wiki_page", wiki_page_id
          end
        end
      end

      # Matches: %user123
      # Renders: a link to the user's user page.
      def parse_user_tags
        content.gsub!(USER_TAG_REGEX) do
          user_id = $LAST_MATCH_INFO[:id]

          if (user = User.find_by(id: user_id))
            user.decorate.ping_user_link
          else
            broken_markdown_link "user", user_id
          end
        end
      end

      # Matches: %dbscript:snaked_base_name or %dbscript:CamelizedBaseName
      # Renders: a link to the database script.
      def parse_dbscript_tags
        content.gsub!(DB_SCRIPT_TAG_REGEX) do
          basename = $LAST_MATCH_INFO[:basename]

          database_script = DatabaseScript.safe_new_from_basename(basename)
          formatted_tags = DatabaseScriptDecorator.new(database_script).format_tags
          link_to(database_script.title, database_script_path(database_script)) << ' ' << formatted_tags
        end
      end

      def broken_markdown_link type, id
        %(<span class="bold-warning">CANNOT FIND #{type.upcase} WITH ID #{id}</span>)
      end
  end
end
