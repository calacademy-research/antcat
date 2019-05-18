# The reason for supporting both "%taxon429349" and "{tax 429349}" is because the
# "%"-style is the original implementation, while the curly braces format is the
# original "taxt" format as used in taxt items.

# TODO: Migrate to support a single tag style only.
# NOTE: The eager loading HACKs make a huge difference on slow pages such as Formicidae.
# Total loading time decreases to 500-600 ms from 1200-1400 ms as measured by rack-mini-profiler in ndev.

module Markdowns
  class ParseAntcatHooks
    include Rails.application.routes.url_helpers
    include ActionView::Helpers::UrlHelper
    include ActionView::Helpers::SanitizeHelper
    include Service

    TAXON_TAG_REGEX = /(%taxon(?<id>\d+))|(\{tax (?<id>\d+)\})/
    REFERENCE_TAG_REGEX = /(%reference(?<id>\d+))|(\{ref (?<id>\d+)\})/

    def initialize content, sanitize_content: true
      @content =  if sanitize_content
                    sanitize(content).to_str
                  else
                    content
                  end
    end

    def call
      parse_taxon_ids!
      parse_reference_ids!
      parse_github_ids!
      parse_user_ids!

      content
    end

    private

      attr_reader :content

      # Matches: %taxon429349 and {tax 429349}
      # Renders: link to the taxon (Formica).
      def parse_taxon_ids!
        # HACK to eager load records in a single query for performance reasons.
        ids = content.scan(TAXON_TAG_REGEX).flatten.compact
        return if ids.blank?

        taxa = Taxon.where(id: ids).select(:id, :name_id, :fossil).includes(:name).index_by(&:id)

        content.gsub!(TAXON_TAG_REGEX) do
          taxon = taxa[$~[:id].to_i]

          if taxon
            taxon.decorate.link_to_taxon
          else
            broken_markdown_link "taxon", $~[:id]
          end
        end
      end

      # Matches: %reference130628 and {ref 130628}
      # Renders: expandable referece as used in the catalog (Abdalla & Cruz-Landim, 2001).
      def parse_reference_ids!
        # HACK to eager load records in a single query for performance reasons.
        refs_ids = content.scan(REFERENCE_TAG_REGEX).flatten.compact
        return if refs_ids.blank?

        refs = Reference.where(id: refs_ids).pluck(:id, :expandable_reference_cache).to_h
        refs = {} if ENV['NO_REF_CACHE']

        content.gsub!(REFERENCE_TAG_REGEX) do
          id = $~[:id]
          begin
            refs[id.to_i]&.html_safe || Reference.find(id).decorate.expandable_reference.html_safe
          rescue
            broken_markdown_link "reference", id
          end
        end
      end

      # Matches: %github123
      # renders: a link to the GitHub issue (including non-existing and PRs).
      def parse_github_ids!
        content.gsub!(/%github(\d+)/) do
          # Also works for PRs because GH figures that out.
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

      def broken_markdown_link type, string
        broken_markdown_link_with_search_history_link type, string
      end

      def broken_markdown_link_with_search_history_link type, id
        <<-HTML.squish
          <span class="bold-warning">
            CANNOT FIND #{type.upcase} WITH ID #{id}#{seach_history_link(id)}
          </span>
        HTML
      end

      def seach_history_link id
        " " + link_to("Search history?", versions_path(item_id: id), class: "btn-normal btn-tiny")
      end
  end
end
