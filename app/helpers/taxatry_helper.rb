module TaxatryHelper
  def all_of_a_taxon rank, selected, super_path = {}
    css_class = 'taxon'
    css_class << ' ' << 'selected' if selected == 'all'
    content_tag :div, :class => css_class do
      link_to 'All', taxatry_path({rank => 'all'}.merge super_path)
    end
  end

  def a_taxon rank, selected, current, super_path = {}
    css_class = 'taxon'
    css_class << ' ' << 'selected' if current == selected
    content_tag :div, :class => css_class do
      link_to current.name.capitalize, taxatry_path({rank => current}.merge super_path)
    end
  end
end
