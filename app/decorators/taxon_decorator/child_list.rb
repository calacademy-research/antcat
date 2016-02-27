class TaxonDecorator::ChildList
  include ActionView::Helpers
  include ActionView::Context
  include ApplicationHelper
  include RefactorHelper
  include CatalogHelper

  def initialize taxon
    @taxon = taxon
  end

  def child_lists
    content = ''.html_safe
    [:subfamilies, :tribes, :genera].each do |rank|
      content << child_lists_for_rank(rank)
    end
    content << collective_group_name_child_list
    return unless content.present?

    content_tag :div, class: 'child_lists' do
      content
    end
  end

  private
    def child_lists_for_rank children_selector
      return ''.html_safe unless @taxon.respond_to?(children_selector) && @taxon.send(children_selector).present?

      if Subfamily === @taxon && children_selector == :genera
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
      extinct = @taxon.child_list_query children_selector, extinct_conditions
      extant = @taxon.child_list_query children_selector, extant_conditions
      specify_extinct_or_extant = extinct.present?

      child_list(extant, specify_extinct_or_extant, extant_conditions) +
      child_list(extinct, specify_extinct_or_extant, extinct_conditions)
    end

    def child_list children, specify_extinct_or_extant, conditions = {}
      return ''.html_safe unless children.present?

      label = ''.html_safe
      label << 'Hong (2002) ' if conditions[:hong]

      if conditions[:collective_group_names]
        label << Status['collective group name'].to_s(children.count).humanize
      else
        label << children.first.rank.pluralize(children.count).titleize
      end

      if specify_extinct_or_extant
        label << ' ('
        label << if conditions[:fossil] then 'extinct' else 'extant' end
        label << ')'
      end

      if conditions[:incertae_sedis_in]
        label << ' <i>incertae sedis</i> in '.html_safe
      elsif conditions[:collective_group_names]
        label << ' in '
      else
        label << ' of '
      end

      label << taxon_label_span(@taxon)

      content_tag :div, class: :child_list do
        content = ''.html_safe
        content << content_tag(:span, label, class: :caption)
        content << ': '
        content << child_list_items(children)
        content << '.'
      end
    end

    def child_list_items children
      children.inject([]) do |string, child|
        string << link_to_taxon(child)
      end.join(', ').html_safe
    end
end
