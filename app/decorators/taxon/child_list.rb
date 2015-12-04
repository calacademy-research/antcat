class TaxonDecorator::ChildList
  include ActionView::Helpers
  include ActionView::Context
  include ApplicationHelper
  include RefactorHelper

  def initialize taxon, user=nil
    @taxon = taxon
    @user = user
  end

  ##########
  public def child_lists
    content = ''.html_safe
    content << child_lists_for_rank(@taxon, :subfamilies)
    content << child_lists_for_rank(@taxon, :tribes)
    content << child_lists_for_rank(@taxon, :genera)
    content << collective_group_name_child_list(@taxon)
    return unless content.present?
    content_tag :div, class: 'child_lists' do
      content
    end
  end

  private def child_lists_for_rank parent, children_selector
    return '' unless parent.respond_to?(children_selector) && parent.send(children_selector).present?

    if Subfamily === parent && children_selector == :genera
      child_list_fossil_pairs(parent, children_selector, incertae_sedis_in: 'subfamily', hong: false) +
      child_list_fossil_pairs(parent, children_selector, incertae_sedis_in: 'subfamily', hong: true)
    else
      child_list_fossil_pairs parent, children_selector
    end
  end

  private def collective_group_name_child_list parent
    children_selector = :collective_group_names
    return '' unless parent.respond_to?(children_selector) && parent.send(children_selector).present?
    child_list parent, parent.send(children_selector), false, collective_group_names: true
  end

  private def child_list_fossil_pairs parent, children_selector, conditions = {}
    extant_conditions = conditions.merge fossil: false
    extinct_conditions = conditions.merge fossil: true
    extinct = parent.child_list_query children_selector, extinct_conditions
    extant = parent.child_list_query children_selector, extant_conditions
    specify_extinct_or_extant = extinct.present?

    child_list(parent, extant, specify_extinct_or_extant, extant_conditions) +
    child_list(parent, extinct, specify_extinct_or_extant, extinct_conditions)
  end

  private def child_list parent, children, specify_extinct_or_extant, conditions = {}
    label = ''.html_safe
    return label unless children.present?

    label << 'Hong (2002) ' if conditions[:hong]

    if conditions[:collective_group_names]
      label << Status['collective group name'].to_s(children.count).humanize
    else
      label << Rank[children].to_s(children.count, conditions[:hong] ? nil : :capitalized)
    end

    if specify_extinct_or_extant
      label << ' ('
      label << (conditions[:fossil] ? 'extinct' : 'extant')
      label << ')'
    end

    if conditions[:incertae_sedis_in]
      label << ' <i>incertae sedis</i> in '.html_safe
    elsif conditions[:collective_group_names]
      label << ' in '
    else
      label << ' of '
    end

    label << Formatters::CatalogFormatter.taxon_label_span(parent, ignore_status: true)

    content_tag :div, class: :child_list do
      content = ''.html_safe
      content << content_tag(:span, label, class: :label)
      content << ': '
      content << child_list_items(children)
      content << '.'
      content
    end
  end

  private def child_list_items children
    children.inject([]) do |string, child|
      string << link_to_taxon(child)
    end.join(', ').html_safe
  end
end