class Views::References::Display < Erector::Widget
  needs :reference

  def content
    div :class => 'reference_display' do
      rawtext format_reference
      rawtext ' '

      a 'add', :href => '#', :class => 'reference_action_link add'
      rawtext ' '
      a 'copy', :href => '#', :class => 'reference_action_link copy'
      rawtext ' '
      a 'delete', :href => '#', :class => 'reference_action_link delete'

      p(:class => 'notes')        {rawtext self.class.italicize(@reference.public_notes)}
      p(:class => 'editor notes') {rawtext self.class.italicize(@reference.editor_notes)}
      p(:class => 'notes')        {rawtext self.class.italicize(@reference.taxonomic_notes)}
    end
  end

  def format_reference
    "#{self.class.italicize(@reference.authors)} " +
    "#{@reference.year}. " +
    "#{self.class.italicize(self.class.add_period_if_necessary(@reference.title))} " +
    "#{self.class.italicize(self.class.add_period_if_necessary(@reference.citation))}"
  end

  private
  def self.add_period_if_necessary s
    return unless s
    return s if s.empty?
    return s + '.' unless s[-1..-1] == '.'
    s
  end

  def self.italicize s
    return unless s
    s = s.html_escape
    s = s.gsub /\*(.*?)\*/, '<span class=taxon>\1</span>'
    s = s.gsub /\|(.*?)\|/, '<span class=taxon>\1</span>'
  end

end
