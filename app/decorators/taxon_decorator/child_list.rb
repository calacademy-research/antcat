# TODO: Cleanup more. This is still the messiest code of AntCat.

class TaxonDecorator::ChildList
  include ActionView::Helpers
  include ActionView::Context
  include Service

  def initialize taxon
    @taxon = taxon
    @lists = []
  end

  def call
    if taxon.is_a?(Family)
      child_list_fossil_pairs(taxon.subfamilies)
      child_list_fossil_pairs(taxon.genera_incertae_sedis_in_family, incertae_sedis_in_label: true)
    end

    if taxon.is_a?(Subfamily)
      child_list_fossil_pairs(taxon.tribes)

      child_list_fossil_pairs(
        taxon.genera_incertae_sedis_in_subfamily.where(hong: false),
        incertae_sedis_in_label: true,
        hong_label: false
      )

      child_list_fossil_pairs(
        taxon.genera_incertae_sedis_in_subfamily.where(hong: true),
        incertae_sedis_in_label: true,
        hong_label: true
      )

      lists << child_list(taxon.collective_group_names, false, collective_group_names_label: true)
    end

    lists.compact
  end

  private

    attr_reader :taxon, :lists

    def child_list_fossil_pairs query, conditions = {}
      extant_conditions = conditions.merge fossil: false
      extinct_conditions = conditions.merge fossil: true

      # HACK: This is Ruby's `#group_by`, not ActiveRecord's `#group`.
      both = query.valid.includes(:name).order_by_name.group_by(&:fossil).to_h
      extinct = both[true] || []
      extant = both[false] || []
      specify_extinct_or_extant = extinct.present?

      lists << child_list(extant, specify_extinct_or_extant, extant_conditions)
      lists << child_list(extinct, specify_extinct_or_extant, extinct_conditions)
    end

    def child_list children, specify_extinct_or_extant, conditions = {}
      return if children.blank?

      {
        label: child_list_label(children, specify_extinct_or_extant, conditions),
        children: children
      }
    end

    def child_list_label children, specify_extinct_or_extant, conditions
      label = ''.html_safe
      label << 'Hong (2002) ' if conditions[:hong_label]

      label << if conditions[:collective_group_names_label]
                 Status::COLLECTIVE_GROUP_NAME.pluralize(children.size).humanize
               else
                 children.first.rank.pluralize(children.size).titleize
               end

      if specify_extinct_or_extant
        label << if conditions[:fossil] then ' (extinct)' else ' (extant)' end
      end

      label << if conditions[:incertae_sedis_in_label]
                 ' <i>incertae sedis</i> in '.html_safe
               elsif conditions[:collective_group_names_label]
                 ' in '
               else
                 ' of '
               end

      label << taxon.epithet_with_fossil
    end
end
