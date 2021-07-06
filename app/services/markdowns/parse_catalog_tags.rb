# frozen_string_literal: true

# TODO: DRY (like find all pro-ish tags in one go and then render them differently). Also `AntwebFormatter::Detax`.

module Markdowns
  class ParseCatalogTags
    include Service

    def initialize content
      @content = content.dup
      @formatter = CatalogFormatter
    end

    def call
      parse_tax_tags
      parse_taxac_tags

      parse_pro_tags
      parse_proac_tags
      parse_prott_tags
      parse_prottac_tags

      parse_ref_tags

      parse_missing_tags
      parse_unmissing_tags
      parse_misspelling_tags

      parse_hiddennotes_tags
      parse_parsertag_tags

      content
    end

    private

      attr_reader :content, :formatter

      # Matches: {tax 429349}
      # Renders: link to taxon (Formica).
      def parse_tax_tags
        # HACK: To eager load records in a single query for performance reasons.
        taxon_ids = Taxt.extract_ids_from_tax_tags(content)
        return if taxon_ids.blank?

        taxa_indexed_by_id = Taxon.where(id: taxon_ids).joins(:protonym).includes(:protonym).select(
          :id, :name_id, :protonym_id, :status, :unresolved_homonym
        ).includes(:name).index_by(&:id)

        content.gsub!(Taxt::TAX_TAG_REGEX) do
          if (taxon = taxa_indexed_by_id[$LAST_MATCH_INFO[:taxon_id].to_i])
            formatter.link_to_taxon(taxon)
          else
            broken_taxt_tag "TAXON", $LAST_MATCH_INFO
          end
        end
      end

      # Matches: {taxac 429349}
      # Renders: link to taxon and show non-linked author citation (Formica Linnaeus, 1758).
      def parse_taxac_tags
        content.gsub!(Taxt::TAXAC_TAG_REGEX) do
          if (taxon = Taxon.find_by(id: $LAST_MATCH_INFO[:taxon_id]))
            formatter.link_to_taxon_with_linked_author_citation(taxon)
          else
            broken_taxt_tag "TAXON", $LAST_MATCH_INFO
          end
        end
      end

      # Matches: {pro 154742}
      # Renders: link to protonym.
      def parse_pro_tags
        content.gsub!(Taxt::PRO_TAG_REGEX) do
          if (protonym = Protonym.find_by(id: $LAST_MATCH_INFO[:protonym_id]))
            formatter.link_to_protonym(protonym)
          else
            broken_taxt_tag "PROTONYM", $LAST_MATCH_INFO
          end
        end
      end

      # Matches: {proac 154742}
      # Renders: link to protonym and link to author citation.
      def parse_proac_tags
        content.gsub!(Taxt::PROAC_TAG_REGEX) do
          if (protonym = Protonym.find_by(id: $LAST_MATCH_INFO[:protonym_id]))
            formatter.link_to_protonym_with_linked_author_citation(protonym)
          else
            broken_taxt_tag "PROTONYM", $LAST_MATCH_INFO
          end
        end
      end

      # Matches: {prott 154742}
      # Renders: link to terminal taxon of protonym.
      def parse_prott_tags
        content.gsub!(Taxt::PROTT_TAG_REGEX) do
          protonym_id = $LAST_MATCH_INFO[:protonym_id]

          if (terminal_taxon = Protonym.terminal_taxon_from_protonym_id(protonym_id))
            formatter.link_to_taxon(terminal_taxon)
          elsif (protonym = Protonym.find_by(id: protonym_id))
            editor_warning = %(<span class="logged-in-only-bold-warning">protonym has no terminal taxon</span>)
            "#{formatter.link_to_protonym(protonym)} (protonym) #{editor_warning}"
          else
            broken_taxt_tag "PROTONYM", $LAST_MATCH_INFO
          end
        end
      end

      # Matches: {prottac 154742}
      # Renders: link to terminal taxon of protonym (with author citation).
      def parse_prottac_tags
        content.gsub!(Taxt::PROTTAC_TAG_REGEX) do
          protonym_id = $LAST_MATCH_INFO[:protonym_id]

          if (terminal_taxon = Protonym.terminal_taxon_from_protonym_id(protonym_id))
            formatter.link_to_taxon_with_linked_author_citation(terminal_taxon)
          elsif (protonym = Protonym.find_by(id: protonym_id))
            editor_warning = %(<span class="logged-in-only-bold-warning">protonym has no terminal taxon</span>)
            "#{formatter.link_to_protonym(protonym)} (protonym) #{editor_warning}"
          else
            broken_taxt_tag "PROTONYM", $LAST_MATCH_INFO
          end
        end
      end

      # Matches: {ref 130628}
      # Renders: expandable referece as used in the catalog (Abdalla & Cruz-Landim, 2001).
      def parse_ref_tags
        # HACK: To eager load records in a single query for performance reasons.
        reference_ids = Taxt.extract_ids_from_reference_tags(content)
        return if reference_ids.blank?

        references_indexed_by_id =
          if ENV['NO_REF_CACHE']
            {}
          else
            Reference.where(id: reference_ids).pluck(:id, :key_with_suffixed_year_cache).to_h
          end

        content.gsub!(Taxt::REF_TAG_REGEX) do
          reference_id = $LAST_MATCH_INFO[:reference_id]

          if (key_with_suffixed_year_cache = references_indexed_by_id[reference_id.to_i])
            formatter.link_to_taxt_reference_cached(reference_id, key_with_suffixed_year_cache)
          elsif (reference = Reference.find_by(id: reference_id))
            formatter.link_to_taxt_reference(reference)
          else
            broken_taxt_tag "REFERENCE", $LAST_MATCH_INFO
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

      # Matches: {misspelling hardcoded name}, which may contain "<i>" tags.
      # Renders: hardcoded name.
      def parse_misspelling_tags
        content.gsub!(Taxt::MISSPELLING_TAG_REGEX) do
          %(<span class="logged-in-only-gray-bold-notice">#{$LAST_MATCH_INFO[:hardcoded_name]}</span>)
        end
      end

      # Hidden editor notes (logged-in only) "{hiddennote string}".
      def parse_hiddennotes_tags
        content.gsub!(Taxt::HIDDENNOTE_TAG_REGEX) do
          %(<span class="taxt-hidden-note"><b>Hidden editor note:</b> #{$LAST_MATCH_INFO[:note_content]}</span>)
        end
      end

      # Hidden parser tags (logged-in only) "{parsertag optional string}".
      def parse_parsertag_tags
        content.gsub!(Taxt::PARSERTAG_TAG_REGEX) do
          %(<span class="taxt-parser-tag"><b>Hidden parser tag</b>#{$LAST_MATCH_INFO[:optional_content]}</span>)
        end
      end

      def broken_taxt_tag type, tag
        %(<span class="bold-warning">CANNOT FIND #{type} FOR TAG #{tag}</span>)
      end
  end
end
