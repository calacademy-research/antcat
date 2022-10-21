# frozen_string_literal: true

# TODO: Refactor/re-write/redo.

module Taxa
  class ChildList
    include Service

    def initialize taxon
      @taxon = taxon
      @lists = []
    end

    def call
      case taxon
      when Family
        child_list(taxon.subfamilies, "Subfamilies of")
        child_list(taxon.genera_incertae_sedis_in, 'Genera <i>incertae sedis</i> in')
      when Subfamily
        child_list(taxon.tribes, "Tribes of")
        child_list(taxon.genera_incertae_sedis_in, 'Genera <i>incertae sedis</i> in')
        child_list(taxon.collective_group_names, "Collective group names in")
      end

      lists
    end

    private

      attr_reader :taxon, :lists

      def child_list query, label
        children = query.valid.includes(:name).order_by_name
        return if children.blank?

        lists << { label: "#{label} #{taxon.name_with_fossil}".html_safe, children: children }
      end
  end
end
