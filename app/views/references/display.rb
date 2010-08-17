class Views::References::Display < Erector::Widget
  needs :reference

  def content
    div :class => 'reference_display' do
      rawtext format_reference(@reference)
      rawtext ' '

      span 'add', :class => 'reference_action_link reference_action_add'
      rawtext ' '
      span 'delete', :class => 'reference_action_link reference_action_delete'

      p(:class => 'notes')        {rawtext italicize(@reference.public_notes)}
      p(:class => 'editor notes') {rawtext italicize(@reference.editor_notes)}
      p(:class => 'notes')        {rawtext italicize(@reference.taxonomic_notes)}
    end
  end

  private
  def format_reference reference
    "#{italicize(reference.authors)} #{reference.year}. #{italicize(reference.title)} #{italicize(reference.citation)}"
  end

  def italicize s
    return unless s
    s = s.html_escape
    s = s.gsub /\*(.*?)\*/, '<span class=taxon>\1</span>'
    s = s.gsub /\|(.*?)\|/, '<span class=taxon>\1</span>'
  end

end
