module TaxatryHelper
  def all_of_a_taxon_link rank, selected, super_path = {}
    content_tag :div, :class => make_css_class('all', selected) do
      link_to 'All', taxatry_path({rank => 'all'}.merge super_path)
    end
  end

  def taxon_link rank, selected, current, super_path = {}
    link rank, selected, current, super_path
  end

  def genus_or_species_link rank, selected, current, super_path = {}
    link rank, selected, current, super_path, 'genus_or_species'
  end

  private
  def link rank, selected, current, super_path, additional_class = ''
    content_tag :div, :class => make_css_class(current, selected, additional_class) do
      fossil_symbol = current.fossil? ? "&dagger;" : ''
      suffix = current.kind_of?(Species) ? '' : "(#{current.children.count})" 
      link_to "#{fossil_symbol}#{current.name}#{suffix}", taxatry_path({rank => current}.merge super_path)
    end
  end

  def make_css_class current, selected, additional_class = ''
    css_classes = ['taxon']
    css_classes << additional_class if additional_class.present?
    css_classes << 'selected' if current == selected
    if current.kind_of? Taxon
      css_classes << 'taxon_unavailable' if current.unavailable?
      css_classes << 'taxon_invalid' if current.invalid?
    end
    css_classes.join ' '
  end

end
