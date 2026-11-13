# frozen_string_literal: true

# Whether a name is already used by a taxon.
module Taxa
  class NameClash
    include Service

    attr_private_initialize :name_string

    def call
      name_clash?
    end

    private

      def name_clash?
        Taxon.where(name_cache: name_string).exists?
      end
  end
end
