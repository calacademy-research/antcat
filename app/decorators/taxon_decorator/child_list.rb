# TODO make this just fetch the taxa, and render the HTML somewhere else.

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
    [:subfamilies, :tribes, :genera].each do |rank|
      content << child_lists_for_rank(rank)
    end
    content << collective_group_name_child_list

    return unless content.present?

    content_tag :div, content, class: 'child_lists'
  end

  private

    def child_lists_for_rank children_selector
      return ''.html_safe unless @taxon.respond_to?(children_selector) && @taxon.send(children_selector).present?

      if @taxon.is_a?(Subfamily) && children_selector == :genera
        child_list_fossil_pairs(children_selector, incertae_sedis_in: 'subfamily', hong: false) +
          child_list_fossil_pairs(children_selector, incertae_sedis_in: 'subfamily', hong: true)
      else
        child_list_fossil_pairs children_selector
      end
    end

    def collective_group_name_child_list
      children_selector = :collective_group_names
      return '' unless @taxon.respond_to?(children_selector) && @taxon.send(children_selector).present?
      child_list @taxon.send(children_selector), false, collective_group_names: true
    end

    def child_list_fossil_pairs children_selector, conditions = {}
      extant_conditions = conditions.merge fossil: false
      extinct_conditions = conditions.merge fossil: true

      extinct = child_list_query children_selector, extinct_conditions
      extant = child_list_query children_selector, extant_conditions

      specify_extinct_or_extant = extinct.present?

      child_list(extant, specify_extinct_or_extant, extant_conditions) +
        child_list(extinct, specify_extinct_or_extant, extinct_conditions)
    end

    def child_list_query children_selector, conditions = {}
      incertae_sedis_in = conditions[:incertae_sedis_in]

      children = @taxon.send children_selector

      children = children.where(fossil: !!conditions[:fossil]) if conditions.key? :fossil
      children = children.where(incertae_sedis_in: incertae_sedis_in) if incertae_sedis_in
      children = children.where(hong: !!conditions[:hong]) if conditions.key? :hong

      children.valid.includes(:name).order_by_name_cache
    end

    def child_list children, specify_extinct_or_extant, conditions = {}
      return ''.html_safe unless children.present?

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

      if conditions[:collective_group_names]
        label << Status['collective group name'].to_s(children.size).humanize
      else
        label << children.first.rank.pluralize(children.size).titleize
      end

      if specify_extinct_or_extant
        label << if conditions[:fossil] then ' (extinct)' else ' (extant)' end
      end

      if conditions[:incertae_sedis_in]
        label << ' <i>incertae sedis</i> in '.html_safe
      elsif conditions[:collective_group_names]
        label << ' in '
      else
        label << ' of '
      end

      label << content_tag(:span, @taxon.taxon_label)
    end

    def child_list_items children
      children.map { |child| link_to_taxon(child) }.join(', ').html_safe
    end

    # TODO refactor more. Formerly based on `$use_ant_web_formatter`.
    def for_antweb?
      @for_antweb
    end

    def link_to_taxon taxon
      if for_antweb?
        Exporters::Antweb::Exporter.antcat_taxon_link_with_name taxon
      else
        taxon.decorate.link_to_taxon
      end
    end
end
