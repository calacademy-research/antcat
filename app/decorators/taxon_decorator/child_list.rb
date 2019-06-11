# TODO: Cleanup more. This is still the messiest code of AntCat.

class TaxonDecorator::ChildList
  include Service

  def initialize taxon
    @taxon = taxon
    @lists = []
  end

  def call
    if taxon.is_a?(Family)
      child_list_fossil_pairs(taxon.subfamilies)
      child_list_fossil_pairs(taxon.genera_incertae_sedis_in_family, incertae_sedis_in: true)
    end

    if taxon.is_a?(Subfamily)
      child_list_fossil_pairs(taxon.tribes)

      child_list_fossil_pairs(
        taxon.genera_incertae_sedis_in_subfamily.where(hong: false),
        incertae_sedis_in: true
      )

      child_list_fossil_pairs(
        taxon.genera_incertae_sedis_in_subfamily.where(hong: true),
        incertae_sedis_in: true,
        hong: true
      )

      child_list(taxon.collective_group_names, false, collective_group_names: true)
    end

    lists.compact
  end

  private

    attr_reader :taxon, :lists

    def child_list_fossil_pairs query, conditions = {}
      # HACK: This is Ruby's `#group_by`, not ActiveRecord's `#group`.
      both = query.valid.includes(:name).order_by_name.group_by(&:fossil).to_h
      extinct = both[true]
      extant = both[false]
      show_extinct_or_extant = extinct.present?

      child_list(extant, show_extinct_or_extant, conditions.merge(fossil: false))
      child_list(extinct, show_extinct_or_extant, conditions.merge(fossil: true))
    end

    def child_list children, show_extinct_or_extant, conditions = {}
      return if children.blank?
      lists << { label: child_list_label(children, show_extinct_or_extant, conditions), children: children }
    end

    def child_list_label children, show_extinct_or_extant, conditions
      label = ''.html_safe
      label << 'Hong (2002) ' if conditions[:hong]

      label << if conditions[:collective_group_names]
                 Status::COLLECTIVE_GROUP_NAME.pluralize(children.size).humanize
               else
                 children.first.rank.pluralize(children.size).titleize
               end

      if show_extinct_or_extant
        label << if conditions[:fossil] then ' (extinct)' else ' (extant)' end
      end

      label << if conditions[:incertae_sedis_in]
                 ' <i>incertae sedis</i> in '.html_safe
               elsif conditions[:collective_group_names]
                 ' in '
               else
                 ' of '
               end

      label << taxon.epithet_with_fossil
    end
end
