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
      child_list_fossil_pairs(:subfamilies)
      child_list_fossil_pairs(:genera_incertae_sedis_in_family)
    end

    if taxon.is_a?(Subfamily)
      child_list_fossil_pairs(:tribes)
      child_list_fossil_pairs(:genera_incertae_sedis_in, incertae_sedis_in: 'subfamily', hong: false)
      child_list_fossil_pairs(:genera_incertae_sedis_in, incertae_sedis_in: 'subfamily', hong: true)
      lists << child_list(taxon.collective_group_names, false, collective_group_names: true)
    end

    lists.compact
  end

  private

    attr_reader :taxon, :lists

    def child_list_fossil_pairs children_selector, conditions = {}
      extant_conditions = conditions.merge fossil: false
      extinct_conditions = conditions.merge fossil: true

      both = child_list_query children_selector, conditions
      extinct = both[true] || []
      extant = both[false] || []
      specify_extinct_or_extant = extinct.present?

      lists << child_list(extant, specify_extinct_or_extant, extant_conditions)
      lists << child_list(extinct, specify_extinct_or_extant, extinct_conditions)
    end

    def child_list_query children_selector, conditions = {}
      incertae_sedis_in = conditions[:incertae_sedis_in]

      children = taxon.send children_selector

      children = children.where(incertae_sedis_in: incertae_sedis_in) if incertae_sedis_in
      children = children.where(hong: !!conditions[:hong]) if conditions.key? :hong

      # HACK: This is Ruby's `#group_by`, not ActiveRecord's `#group`.
      children.valid.includes(:name).order_by_name.group_by(&:fossil).to_h
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
      label << 'Hong (2002) ' if conditions[:hong]

      label << if conditions[:collective_group_names]
                 Status::COLLECTIVE_GROUP_NAME.pluralize(children.size).humanize
               else
                 children.first.rank.pluralize(children.size).titleize
               end

      if specify_extinct_or_extant
        label << if conditions[:fossil] then ' (extinct)' else ' (extant)' end
      end

      label << if conditions[:incertae_sedis_in] || formicidae_incertae_sedis_genera?(taxon, children)
                 ' <i>incertae sedis</i> in '.html_safe
               elsif conditions[:collective_group_names]
                 ' in '
               else
                 ' of '
               end

      label << taxon.epithet_with_fossil
    end

    # TODO see https://github.com/calacademy-research/antcat/issues/453
    def formicidae_incertae_sedis_genera? taxon, children
      taxon.is_a?(Family) && children.first.is_a?(Genus)
    end
end
