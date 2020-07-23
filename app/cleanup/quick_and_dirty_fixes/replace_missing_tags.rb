# frozen_string_literal: true

# TODO: Temporary code for `QuickAndDirtyFixesController#replace_missing_tags`.
module QuickAndDirtyFixes
  class ReplaceMissingTags
    include Service

    def initialize taxt
      @taxt = taxt
    end

    def call
      replace_missing_tags
    end

    def target_for_replacement
      @_target_for_replacement ||= hardcoded_names_with_taxa.first # Only replace one at a time.
    end

    def can_be_quick_fixed?
      target_for_replacement[:taxa].size == 1
    end

    def hardcoded_names
      @_hardcoded_names ||= taxt.scan(Taxt::MISSING_TAG_REGEX).flatten.map do |hardcoded_name|
        [hardcoded_name, Unitalicize[hardcoded_name.html_safe].strip]
      end
    end

    def hardcoded_names_with_taxa
      hardcoded_names.map do |hardcoded_name, normalized_name|
        taxa = Taxon.where(name_cache: normalized_name)

        {
          hardcoded_name: hardcoded_name,
          normalized_name: normalized_name,
          taxa: taxa.load
        }
      end
    end

    private

      attr_reader :taxt

      def replace_missing_tags
        return unless can_be_quick_fixed?

        hardcoded_name = target_for_replacement[:hardcoded_name]
        taxon = target_for_replacement[:taxa].first

        new_taxt = taxt.dup
        new_taxt.gsub!(/\{missing[0-9]? #{hardcoded_name}\}/, "{tax #{taxon.id}}")

        new_taxt
      end
  end
end
