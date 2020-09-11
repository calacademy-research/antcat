# frozen_string_literal: true

module Markdowns
  class BoltonKeysToRefTags
    include Service

    attr_private_initialize :bolton_content

    def call
      replace_with_ref_tags
    end

    private

      def replace_with_ref_tags
        split_by_semicolon.map do |part|
          part.gsub(/(?<bolton_key>.*?):/) do
            reference = find_reference $LAST_MATCH_INFO[:bolton_key]
            if reference
              "{ref #{reference.id}}:"
            else
              "#{Regexp.last_match(1)}: "
            end
          end
        end.join("; ").gsub("  ", " ")
      end

      def split_by_semicolon
        bolton_content.split("; ")
      end

      def find_reference bolton_key
        Reference.find_by(bolton_key: normalize_bolton_key(bolton_key))
      end

      def normalize_bolton_key bolton_key
        bolton_key.remove(",", "&").gsub("  ", " ").strip
      end
  end
end
