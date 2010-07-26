class Views::References::Index < Views::Base

  include ActionController::UrlWriter

  def container_content
    div do
      widget Views::Search.new
    end
    div :style => 'float:right;margin-top: 5px' do
      rawtext will_paginate @references
    end

    div :style => 'clear:both'
    
    hr

    unless @references.present?
      rawtext 'No results found'
    else
      table do
        for reference in @references
          tr do
            td :class => 'reference' do
              a :href => reference_path(reference) do
                rawtext format_reference(reference)
              end
              widget Views::Coins.new :reference => reference
            end
          end
        end
      end
    end

    p
    rawtext link_to "New Reference", new_reference_path
  end

  def format_reference reference
    "#{italicize(reference.authors)} #{reference.year}. #{italicize(reference.title)} #{italicize(reference.citation)} #{italicize(reference.notes)}"
  end

  def italicize s
    return unless s
    s = s.html_escape
    s = s.gsub /\*(.*?)\*/, '<span class=taxon>\1</span>'
    s = s.gsub /\|(.*?)\|/, '<span class=taxon>\1</span>'
  end

end
