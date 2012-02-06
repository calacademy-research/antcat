# coding: UTF-8
class Formatter

  def self.format_conjuncted_list items, css_class
    items = items.flatten.uniq.map{|item| %{<span class="#{css_class}">#{item}</span>}}.sort
    case
    when items.count == 0
      ''
    when items.count == 1
      items.first
    when items.count == 2
      items.first + ' and ' + items.second
    else
      items[0..-2].join(', ') + ' and ' + items.last
    end.html_safe
  end

end

