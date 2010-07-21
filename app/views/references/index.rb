class Views::References::Index < Views::Base

  include ActionController::UrlWriter

  def container_content
    div :id => 'search' do
      widget Form, :action => '/references', :method => 'get' do
        label 'Author', :for => 'author'
        input :name => 'author', :id => 'author', :type => 'text', :value => params[:author]
        label 'Year', :for => 'start_year'
        input :name => 'start_year', :id => 'start_year', :class => 'year', :type => 'text', :value => params[:start_year]
        label 'to', :for => 'end_year'
        input :name => 'end_year', :id => 'end_year', :class => 'year', :type => 'text', :value => params[:end_year]
        button 'Search', :value => 'search', :name => 'commit', :type => 'submit'
        button 'Clear', :value => 'clear', :name => 'commit', :type => 'submit'
      end
    end

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
            end
          end
        end
      end
    end

    p
    rawtext will_paginate @references
    p
    rawtext link_to "New Reference", new_reference_path
    lll { 'self.class.dependencies(:js)' }
  end

  def format_reference reference
    "#{italicize(reference.authors)} #{reference.year} #{italicize(reference.title)} #{italicize(reference.citation)} #{italicize(reference.notes)}"
  end

  def italicize s
    return unless s
    s.html_escape.gsub /\*(.*?)\*/, '<span class=taxon>\1</span>'
  end

end
