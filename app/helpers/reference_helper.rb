module ReferenceHelper
  def format_reference reference
    s = ''
    s << "#{h reference.authors_string} "
    s << "#{h reference.citation_year}. "
    s << "#{italicize(Reference.add_period_if_necessary(h reference.title))} "
    s << "#{italicize(Reference.add_period_if_necessary(h reference.citation_string))}"
    s << " [#{format_date(reference.date)}]" if reference.date.present?
    s
  end

  def italicize s
    return unless s
    s = s.gsub /\*(.*?)\*/, '<span class=taxon>\1</span>'
    s = s.gsub /\|(.*?)\|/, '<span class=taxon>\1</span>'
  end

  private
  def format_date input
    date = input
    return date if input.length < 4

    match = input.match(/(.*?)(\d{4,8})(.*)/)
    prefix = match[1]
    input = match[2]
    suffix = match[3]

    date = input[0, 4]
    return prefix + date + suffix if input.length < 6
    date << '-' << input[4, 2]
    return prefix + date + suffix if input.length < 8
    date << '-' << input[6, 2]
    prefix + date + suffix
  end
end
