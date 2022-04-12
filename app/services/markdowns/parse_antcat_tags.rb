# frozen_string_literal: true

module Markdowns
  class ParseAntCatTags
    include Rails.application.routes.url_helpers
    include ActionView::Helpers::UrlHelper
    include Service

    USER_TAG_REGEX = /@user(?<user_id>\d+)/
    GITHUB_TAG_REGEX = /%github(?<issue_id>\d+)/
    WIKI_TAG_REGEX = /%wiki(?<wiki_page_id>\d+)/
    DBSCRIPT_TAG_REGEX = /%dbscript:(?<basename>[A-Z][A-Za-z0-9_]+)/

    GITHUB_ISSUES_BASE_URL = "https://github.com/calacademy-research/antcat/issues/"

    def initialize content
      @content = content.dup
    end

    def call
      parse_github_tags
      parse_user_tags
      parse_dbscript_tags
      parse_wiki_tags

      content
    end

    private

      attr_reader :content

      # Matches: %github123
      # renders: a link to the GitHub issue (including non-existing and PRs).
      def parse_github_tags
        content.gsub!(GITHUB_TAG_REGEX) do
          github_issue_id = $LAST_MATCH_INFO[:issue_id]
          link_to "GitHub ##{github_issue_id}", "#{GITHUB_ISSUES_BASE_URL}#{github_issue_id}"
        end
      end

      # Matches: @user123
      # Renders: a link to the user's user page.
      def parse_user_tags
        content.gsub!(USER_TAG_REGEX) do
          if (user = User.find_by(id: $LAST_MATCH_INFO[:user_id]))
            user.decorate.ping_user_link
          else
            broken_taxt_tag "USER", $LAST_MATCH_INFO
          end
        end
      end

      # Matches: %dbscript:CamelizedBaseName
      # Renders: a link to the database script.
      def parse_dbscript_tags
        content.gsub!(DBSCRIPT_TAG_REGEX) do
          basename = $LAST_MATCH_INFO[:basename]

          database_script = DatabaseScript.safe_new_from_basename(basename)
          formatted_tags = DatabaseScriptDecorator.new(database_script).format_tags
          link_to(database_script.title, database_script_path(database_script)) << ' ' << formatted_tags
        end
      end

      # Matches: %wiki123
      # Renders: a link to the wiki page.
      def parse_wiki_tags
        content.gsub!(WIKI_TAG_REGEX) do
          if (wiki_page = WikiPage.find_by(id: $LAST_MATCH_INFO[:wiki_page_id]))
            link_to wiki_page.title, wiki_page_path(wiki_page.id)
          else
            broken_taxt_tag "WIKI_PAGE", $LAST_MATCH_INFO
          end
        end
      end

      def broken_taxt_tag type, tag
        %(<span class="bold-warning">CANNOT FIND #{type} FOR TAG #{tag}</span>)
      end
  end
end
