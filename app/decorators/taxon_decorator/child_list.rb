# TODO make this just fetch the taxa, and render the HTML somewhere else.
# TODO Some branches are unreachable because `taxon.respond_to?(children_selector)` is false.

class TaxonDecorator::ChildList
  include ActionView::Helpers
  include ActionView::Context
  include Service

  def initialize taxon, for_antweb: false
    @taxon = taxon
    @for_antweb = for_antweb
  end

  def call
    content = ''.html_safe

    if taxon.is_a?(Family)
      content << child_lists_for_rank(:subfamilies)
    end

    if taxon.is_a?(Subfamily)
      content << child_lists_for_rank(:tribes)
    end

    if taxon.is_a?(Subfamily) || taxon.is_a?(Family)
      content << child_lists_for_rank(:genera_incertae_sedis_in)
    end

    content << collective_group_name_child_list if taxon.is_a?(Subfamily)

    content
  end

  private

    attr_reader :taxon

    def child_lists_for_rank children_selector
      return ''.html_safe unless taxon.send(children_selector)

      if taxon.is_a?(Subfamily) && children_selector == :genera
        # TODO this is never triggered since there is no `Subfamily#genera`,
        # and `:genera` was replaced with `:genera_incertae_sedis_in`.
        child_list_fossil_pairs(children_selector, incertae_sedis_in: 'subfamily', hong: false) +
          child_list_fossil_pairs(children_selector, incertae_sedis_in: 'subfamily', hong: true)
      else
        child_list_fossil_pairs children_selector
      end
    end

    def collective_group_name_child_list
      child_list taxon.collective_group_names, false, collective_group_names: true
    end

    def child_list_fossil_pairs children_selector, conditions = {}
      extant_conditions = conditions.merge fossil: false
      extinct_conditions = conditions.merge fossil: true

      both = child_list_query children_selector, conditions
      extinct = both[true] || []
      extant = both[false] || []
      specify_extinct_or_extant = extinct.present?

      child_list(extant, specify_extinct_or_extant, extant_conditions) +
        child_list(extinct, specify_extinct_or_extant, extinct_conditions)
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
      return ''.html_safe if children.blank?

      label = child_list_label children, specify_extinct_or_extant, conditions
      content_tag :div do
        content = ''.html_safe
        content << content_tag(:span, label, class: 'caption')
        content << ': '
        content << child_list_items(children)
        content << '.'
      end
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

      label << content_tag(:span, taxon.epithet_with_fossil)
    end

    # TODO see https://github.com/calacademy-research/antcat/issues/453
    def formicidae_incertae_sedis_genera? taxon, children
      taxon.is_a?(Family) && children.first.is_a?(Genus)
    end

    def child_list_items children
      if for_antweb?
        children.map { |child| Exporters::Antweb::Exporter.antcat_taxon_link_with_name child }
      else
        children.map { |child| child.decorate.link_to_taxon }
      end.join(', ').html_safe
    end

    # TODO refactor more. Formerly based on `$use_ant_web_formatter`.
    def for_antweb?
      @for_antweb
    end
end
