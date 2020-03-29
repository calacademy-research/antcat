# frozen_string_literal: true

require 'English'

# The reason for supporting both "%taxon429349" and "{tax 429349}" is because the
# "%"-style is the original implementation, while the curly braces format is the
# original "taxt" format as used in taxt items.

# TODO: Migrate to support a single tag style only.
# NOTE: The eager loading HACKs make a huge difference on slow pages such as Formicidae.
# Total loading time decreases to 500-600 ms from 1200-1400 ms as measured by rack-mini-profiler in dev.

module Markdowns
  class ParseAntcatHooks
    include Rails.application.routes.url_helpers
    include ActionView::Helpers::UrlHelper
    include ActionView::Helpers::SanitizeHelper
    include Service

    USER_TAG_REGEX = /@user(\d+)/
    GITHUB_TAG_REGEX = /%github(\d+)/
    WIKI_TAG_REGEX = /%wiki(\d+)/
    DB_SCRIPT_TAG_REGEX = /%dbscript:([A-Z][A-Za-z0-9_]+)/

    def initialize content, sanitize_content: true, catalog_tags_only: false
      @content = if sanitize_content
                   sanitize(content).to_str
                 else
                   content
                 end
      # TODO: Ugly control couple, added as a step before a proper split.
      @catalog_tags_only = catalog_tags_only
    end

    def call
      parse_taxon_ids
      parse_taxon_with_author_citation_ids
      parse_reference_ids
      return content if catalog_tags_only

      parse_github_ids
      parse_wiki_pages_ids
      parse_user_ids
      parse_database_script_ids

      content
    end

    private

      attr_reader :content, :catalog_tags_only

      # Matches: %taxon429349 and {tax 429349}
      # Renders: link to the taxon (Formica).
      def parse_taxon_ids
        # HACK: To eager load records in a single query for performance reasons.
        ids = content.scan(Taxt::TAX_TAG_REGEX).flatten.compact
        return if ids.blank?

        taxa = Taxon.where(id: ids).select(:id, :name_id, :fossil).includes(:name).index_by(&:id)

        content.gsub!(Taxt::TAX_TAG_REGEX) do
          taxon = taxa[$LAST_MATCH_INFO[:id].to_i]

          if taxon
            taxon.link_to_taxon
          else
            broken_markdown_link "taxon", $LAST_MATCH_INFO[:id]
          end
        end
      end

      # Matches: {taxac 429349}
      # Renders: link to the taxon and show non-linked author citation (Formica Linnaeus, 1758).
      def parse_taxon_with_author_citation_ids
        content.gsub!(Taxt::TAXAC_TAG_REGEX) do
          taxon = Taxon.find_by(id: $LAST_MATCH_INFO[:id])

          if taxon
            taxon.decorate.link_to_taxon_with_author_citation
          else
            broken_markdown_link "taxon", $LAST_MATCH_INFO[:id]
          end
        end
      end

      # Matches: %reference130628 and {ref 130628}
      # Renders: expandable referece as used in the catalog (Abdalla & Cruz-Landim, 2001).
      def parse_reference_ids
        # HACK: To eager load records in a single query for performance reasons.
        refs_ids = content.scan(Taxt::REF_TAG_REGEX).flatten.compact
        return if refs_ids.blank?

        refs = Reference.where(id: refs_ids).pluck(:id, :expandable_reference_cache).to_h
        refs = {} if ENV['NO_REF_CACHE']

        content.gsub!(Taxt::REF_TAG_REGEX) do
          id = $LAST_MATCH_INFO[:id]
          begin
            refs[id.to_i]&.html_safe || Reference.find(id).decorate.expandable_reference.html_safe
          rescue ActiveRecord::RecordNotFound
            broken_markdown_link "reference", id
          end
        end
      end

      # Matches: %github123
      # renders: a link to the GitHub issue (including non-existing and PRs).
      def parse_github_ids
        content.gsub!(GITHUB_TAG_REGEX) do
          # Also works for PRs because GH figures that out.
          github_issue_id = Regexp.last_match(1)
          url = "https://github.com/calacademy-research/antcat/issues/#{github_issue_id}"
          link_to "GitHub ##{github_issue_id}", url
        end
      end

      # Matches: %wiki123
      # Renders: a link to the wiki page.
      def parse_wiki_pages_ids
        content.gsub!(WIKI_TAG_REGEX) do
          wiki_page_id = Regexp.last_match(1)
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
      def parse_user_ids
        content.gsub!(USER_TAG_REGEX) do
          user_id = Regexp.last_match(1)
          user = User.find_by(id: user_id)
          if user
            user.decorate.ping_user_link
          else
            broken_markdown_link "user", user_id
          end
        end
      end

      # Matches: %dbscript:filename_without_extension or %dbscript:FilenameWithoutExtension
      # Renders: a link to the database script.
      def parse_database_script_ids
        content.gsub!(DB_SCRIPT_TAG_REGEX) do
          filename = Regexp.last_match(1)
          database_script = DatabaseScript.safe_new_from_filename_without_extension(filename)
          formatted_tags = DatabaseScriptDecorator.new(database_script).format_tags
          link_to(database_script.title, database_script_path(database_script)) << ' ' << formatted_tags
        end
      end

      def broken_markdown_link type, id
        <<-HTML.squish
          <span class="bold-warning">
            CANNOT FIND #{type.upcase} WITH ID #{id}
          </span>
        HTML
      end
  end
end
