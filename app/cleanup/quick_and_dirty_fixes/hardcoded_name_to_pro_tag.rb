# frozen_string_literal: true

# TMPCLEANUP: Temporary code for `QuickAndDirtyFixesController#replace_with_pro_tags`.
module QuickAndDirtyFixes
  class HardcodedNameToProTag
    include Service

    def initialize history_item
      @history_item = history_item
    end

    def call
      replace_with_pro_tag
    end

    private

      attr_reader :history_item

      def replace_with_pro_tag
        protonym = history_item.taxon.protonym

        new_taxt = history_item.taxt.dup
        new_taxt.gsub!(/^#{protonym.name.name}/, "{pro #{protonym.id}}")

        new_taxt
      end
  end
end
