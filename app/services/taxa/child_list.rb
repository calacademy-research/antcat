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
      if taxon.is_a?(::Family)
        child_list(taxon.subfamilies)
        child_list(taxon.genera_incertae_sedis_in, incertae_sedis_in: true)
      end

      if taxon.is_a?(::Subfamily)
        child_list(taxon.tribes)
        child_list(taxon.genera_incertae_sedis_in, incertae_sedis_in: true)
        child_list(taxon.collective_group_names, collective_group_names: true)
      end

      lists
    end

    private

      attr_reader :taxon, :lists

      def child_list query, label_options = {}
        children = query.valid.includes(:name).order_by_name
        return if children.blank?

        lists << { label: child_list_label(children, label_options), children: children }
      end

      def child_list_label children, label_options
        label = ''.html_safe

        label << if label_options[:collective_group_names]
                   "Collective group names"
                 else
                   children.first.rank.pluralize.titleize
                 end

        label << if label_options[:incertae_sedis_in]
                   ' <i>incertae sedis</i> in '.html_safe
                 elsif label_options[:collective_group_names]
                   ' in '
                 else
                   ' of '
                 end

        label << taxon.name_with_fossil
      end
  end
end
