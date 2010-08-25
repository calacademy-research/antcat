module ReferenceHelper
  def format_reference reference
    "#{italicize(h reference.authors)} " +
    "#{h reference.year}. " +
    "#{italicize(add_period_if_necessary(h reference.title))} " +
    "#{italicize(add_period_if_necessary(h reference.citation))}"
  end

  def italicize s
    return unless s
    s = s.gsub /\*(.*?)\*/, '<span class=taxon>\1</span>'
    s = s.gsub /\|(.*?)\|/, '<span class=taxon>\1</span>'
  end

  private
  def add_period_if_necessary s
    return unless s
    return s if s.empty?
    return s + '.' unless s[-1..-1] == '.'
    s
  end

end
