# frozen_string_literal: true

require 'English'

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

      parse_pro_tags

      parse_missing_tags
      parse_unmissing_tags

      content
    end

    private

      attr_reader :content

      # Matches: %taxon429349 and {tax 429349}
      # Renders: link to the taxon (Formica).
      def parse_tax_tags
        # HACK: To eager load records in a single query for performance reasons.
        taxon_ids = content.scan(Taxt::TAX_TAG_REGEX).flatten.compact
        return if taxon_ids.blank?

        taxa_indexed_by_id = Taxon.where(id: taxon_ids).select(
          :id, :name_id, :fossil, :status, :unresolved_homonym
        ).includes(:name).index_by(&:id)

        content.gsub!(Taxt::TAX_TAG_REGEX) do
          taxon_id = $LAST_MATCH_INFO[:id]

          if (taxon = taxa_indexed_by_id[taxon_id.to_i])
            CatalogFormatter.link_to_taxon(taxon)
          else
            broken_taxt_tag "TAXON", taxon_id
          end
        end
      end

      # Matches: {taxac 429349}
      # Renders: link to the taxon and show non-linked author citation (Formica Linnaeus, 1758).
      def parse_taxac_tags
        content.gsub!(Taxt::TAXAC_TAG_REGEX) do
          taxon_id = $LAST_MATCH_INFO[:id]

          if (taxon = Taxon.find_by(id: taxon_id))
            taxon.decorate.link_to_taxon_with_linked_author_citation
          else
            broken_taxt_tag "TAXON", taxon_id
          end
        end
      end

      # Matches: %reference130628 and {ref 130628}
      # Renders: expandable referece as used in the catalog (Abdalla & Cruz-Landim, 2001).
      def parse_ref_tags
        # HACK: To eager load records in a single query for performance reasons.
        reference_ids = content.scan(Taxt::REF_TAG_REGEX).flatten.compact
        return if reference_ids.blank?

        references_indexed_by_id =
          if ENV['NO_REF_CACHE']
            {}
          else
            Reference.where(id: reference_ids).pluck(:id, :expandable_reference_cache).to_h
          end

        content.gsub!(Taxt::REF_TAG_REGEX) do
          reference_id = $LAST_MATCH_INFO[:id]

          if (expandable_reference_cache = references_indexed_by_id[reference_id.to_i])
            expandable_reference_cache.html_safe
          elsif (reference = Reference.find_by(id: reference_id))
            reference.decorate.expandable_reference.html_safe
          else
            broken_taxt_tag "REFERENCE", reference_id
          end
        end
      end

      # Matches: {pro 154742}
      # Renders: link to the protonym
      def parse_pro_tags
        content.gsub!(Taxt::PRO_TAG_REGEX) do
          protonym_id = $LAST_MATCH_INFO[:id]

          if (protonym = Protonym.find_by(id: protonym_id))
            protonym.decorate.link_to_protonym
          else
            broken_taxt_tag "PROTONYM", protonym_id
          end
        end
      end

      # Matches: {missing hardcoded name}, which may contain "<i>" tags.
      # Renders: hardcoded name.
      def parse_missing_tags
        content.gsub!(Taxt::MISSING_TAG_REGEX) do
          %(<span class="logged-in-only-bold-warning">#{$LAST_MATCH_INFO[:hardcoded_name]}</span>)
        end
      end

      # Matches: {unmissing hardcoded name}, which may contain "<i>" tags.
      # Renders: hardcoded name.
      def parse_unmissing_tags
        content.gsub!(Taxt::UNMISSING_TAG_REGEX) do
          %(<span class="logged-in-only-gray-bold-notice">#{$LAST_MATCH_INFO[:hardcoded_name]}</span>)
        end
      end

      def broken_taxt_tag type, id
        %(<span class="bold-warning">CANNOT FIND #{type} WITH ID #{id}</span>)
      end
  end
end
