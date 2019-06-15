# TODO: Cleanup more. This is still the messiest code of AntCat.

module Taxa
  class ChildList
    include Service

    def initialize taxon
      @taxon = taxon
      @lists = []
    end

    def call
      if taxon.is_a?(Family)
        child_list_fossil_pairs(taxon.subfamilies)
        child_list_fossil_pairs(taxon.genera_incertae_sedis_in, incertae_sedis_in: true)
      end

      if taxon.is_a?(Subfamily)
        child_list_fossil_pairs(taxon.tribes)

        child_list_fossil_pairs(
          taxon.genera_incertae_sedis_in.where(hong: false),
          incertae_sedis_in: true
        )

        child_list_fossil_pairs(
          taxon.genera_incertae_sedis_in.where(hong: true),
          incertae_sedis_in: true,
          hong: true
        )

        child_list(taxon.collective_group_names, false, collective_group_names: true)
      end

      lists.compact
    end

    private

      attr_reader :taxon, :lists

      def child_list_fossil_pairs query, label_options = {}
        # HACK: This is Ruby's `#group_by`, not ActiveRecord's `#group`.
        both = query.valid.includes(:name).order_by_name.group_by(&:fossil).to_h
        extinct = both[true]
        extant = both[false]
        show_extinct_or_extant = extinct.present?

        child_list(extant, show_extinct_or_extant, label_options.merge(fossil: false))
        child_list(extinct, show_extinct_or_extant, label_options.merge(fossil: true))
      end

      def child_list children, show_extinct_or_extant, label_options = {}
        return if children.blank?
        lists << { label: child_list_label(children, show_extinct_or_extant, label_options), children: children }
      end

      def child_list_label children, show_extinct_or_extant, label_options
        label = ''.html_safe
        label << 'Hong (2002) ' if label_options[:hong]

        label << if label_options[:collective_group_names]
                   Status::COLLECTIVE_GROUP_NAME.pluralize(children.size).humanize
                 else
                   children.first.rank.pluralize(children.size).titleize
                 end

        if show_extinct_or_extant
          label << if label_options[:fossil] then ' (extinct)' else ' (extant)' end
        end

        label << if label_options[:incertae_sedis_in]
                   ' <i>incertae sedis</i> in '.html_safe
                 elsif label_options[:collective_group_names]
                   ' in '
                 else
                   ' of '
                 end

        label << taxon.epithet_with_fossil
      end
  end
end
