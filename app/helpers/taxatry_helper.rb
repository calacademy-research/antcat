module TaxatryHelper
  def all_of_a_taxon_link rank, selected, super_path = {}
    content_tag :div, :class => make_css_class(selected == 'all') do
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
    content_tag :div, :class => make_css_class(current == selected, additional_class) do
      link_to current.name, taxatry_path({rank => current}.merge super_path)
    end
  end

  def make_css_class selected = false, additional_class = ''
    css_class = "taxon #{additional_class}"
    css_class << ' ' << 'selected' if selected
    css_class
  end

end
