module Markdowns
  class BoltonKeysToRefTags
    include Service

    def initialize bolton_content
      @bolton_content = bolton_content
    end

    def call
      replace_with_ref_tags
    end

    private

      attr_reader :bolton_content

      def replace_with_ref_tags
        split_by_semicolon.map do |part|
          part.gsub(/(?<bolton_key>.*?):/) do
            reference = find_reference $~[:bolton_key]
            if reference
              "{ref #{reference.id}}:"
            else
              "#{$1}: "
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
        bolton_key.tr(",", "").strip
      end
  end
end
