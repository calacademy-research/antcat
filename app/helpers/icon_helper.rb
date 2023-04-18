# frozen_string_literal: true

module IconHelper
  def antcat_icon *css_classes
    tag.i nil, class: ["antcat_icon"].concat(Array.wrap(css_classes))
  end

  def search_icon
    antcat_icon "search"
  end

  def append_superadmin_icon label
    label.html_safe << antcat_icon("superadmin")
  end
end
