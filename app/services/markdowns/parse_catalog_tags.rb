# frozen_string_literal: true

require 'English'

# The reason for supporting both "%taxon429349" and "{tax 429349}" is because the
# "%"-style is the original implementation, while the curly braces format is the
# original "taxt" format as used in taxt items.

module Markdowns
  class ParseCatalogTags
    include ActionView::Helpers::SanitizeHelper
    include Service

    def initialize content, sanitize_content: true
      @content = sanitize_content ? sanitize(content).to_str : content
    end

    def call
      parse_tax_tags
      parse_taxac_tags
      parse_ref_tags

      content
    end

    private

      attr_reader :content

      # Matches: %taxon429349 and {tax 429349}
      # Renders: link to the taxon (Formica).
      def parse_tax_tags
        # HACK: To eager load records in a single query for performance reasons.
        ids = content.scan(Taxt::TAX_TAG_REGEX).flatten.compact
        return if ids.blank?

        taxa = Taxon.where(id: ids).select(:id, :name_id, :fossil).includes(:name).index_by(&:id)

        content.gsub!(Taxt::TAX_TAG_REGEX) do
          if (taxon = taxa[$LAST_MATCH_INFO[:id].to_i])
            taxon.link_to_taxon
          else
            broken_markdown_link "taxon", $LAST_MATCH_INFO[:id]
          end
        end
      end

      # Matches: {taxac 429349}
      # Renders: link to the taxon and show non-linked author citation (Formica Linnaeus, 1758).
      def parse_taxac_tags
        content.gsub!(Taxt::TAXAC_TAG_REGEX) do
          if (taxon = Taxon.find_by(id: $LAST_MATCH_INFO[:id]))
            taxon.decorate.link_to_taxon_with_linked_author_citation
          else
            broken_markdown_link "taxon", $LAST_MATCH_INFO[:id]
          end
        end
      end

      # Matches: %reference130628 and {ref 130628}
      # Renders: expandable referece as used in the catalog (Abdalla & Cruz-Landim, 2001).
      def parse_ref_tags
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

      def broken_markdown_link type, id
        %(<span class="bold-warning">CANNOT FIND #{type.upcase} WITH ID #{id}</span>)
      end
  end
end
