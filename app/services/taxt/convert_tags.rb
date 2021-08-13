# frozen_string_literal: true

module Taxt
  class ConvertTags
    include Service

    TAXON_TO_PROTONYM_REGEX =
      /\{(?:#{Taxt::TAXON_TAGS.join('|')}) (?<taxon_id>\d+)(?<to_tag>(?:#{Taxt::PROTONYM_TAGS.join('|')}))\}/
    PROTONYM_TO_TAXON_REGEX =
      /\{(?:#{Taxt::PROTONYM_TAGS.join('|')}) (?<protonym_id>\d+)(?<to_tag>(?:#{Taxt::TAXON_TAGS.join('|')}))\}/

    def initialize taxt
      @taxt = taxt.try(:dup)
    end

    def call
      return if taxt.nil?
      raise unless taxt.is_a?(String)

      convert_taxon_to_protonym_tags
      convert_protonym_to_taxon_tags

      taxt
    end

    private

      attr_reader :taxt

      def convert_taxon_to_protonym_tags
        taxt.gsub!(TAXON_TO_PROTONYM_REGEX) do
          if (taxon = Taxon.find_by(id: $LAST_MATCH_INFO[:taxon_id]))
            to_tag = $LAST_MATCH_INFO[:to_tag]
            "{#{to_tag} #{taxon.protonym.id}}"
          else
            $LAST_MATCH_INFO
          end
        end
      end

      def convert_protonym_to_taxon_tags
        taxt.gsub!(PROTONYM_TO_TAXON_REGEX) do
          protonym = Protonym.find_by(id: $LAST_MATCH_INFO[:protonym_id])

          if protonym&.terminal_taxon
            to_tag = $LAST_MATCH_INFO[:to_tag]
            "{#{to_tag} #{protonym.terminal_taxon.id}}"
          else
            $LAST_MATCH_INFO
          end
        end
      end
  end
end
