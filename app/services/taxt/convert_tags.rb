# frozen_string_literal: true

module Taxt
  class ConvertTags
    include Service

    TAX_TO_PROTONYM_REGEX = /\{#{Taxt::TAX_TAG} (?<taxon_id>\d+)(?<to_tag>(?:p|#{Taxt::PROTONYM_TAGS.join('|')}))\}/
    SHORTCUTS = {
      'p' => 'pro'
    }

    def initialize taxt
      @taxt = taxt.try(:dup)
    end

    def call
      return if taxt.nil?
      raise unless taxt.is_a?(String)

      convert_tax_to_protonym_tags

      taxt
    end

    private

      attr_reader :taxt

      def convert_tax_to_protonym_tags
        taxt.gsub!(TAX_TO_PROTONYM_REGEX) do
          if (taxon = Taxon.find_by(id: $LAST_MATCH_INFO[:taxon_id]))
            to_tag = $LAST_MATCH_INFO[:to_tag]
            "{#{SHORTCUTS[to_tag] || to_tag} #{taxon.protonym.id}}"
          else
            $LAST_MATCH_INFO
          end
        end
      end
  end
end
