class Views::References::Index < Erector::Widgets::Page

  include ActionController::UrlWriter

  def head_content
    super
    javascript_include_tag 'ext/jquery-1.4.2.js'
    css '/stylesheets/application.css'
    jquery "$('input').first().focus()"
  end

  def page_title
    'ANTBIB'
  end

  def format_reference reference
    "#{italicize(reference.authors)} #{reference.year} #{italicize(reference.title)} #{italicize(reference.citation)} #{italicize(reference.notes)}"
  end

  def italicize s
    return unless s
    s.html_escape.gsub /\*(.*?)\*/, '<span class=taxon>\1</span>'
  end

  def body_content
    div :id => 'container' do
      h3 'ANTBIB'

      hr
      
      div :id => 'search' do
        widget Form, :action => '/references', :method => 'get' do
          label 'Author', :for => 'author'
          input :name => 'author', :id => 'author', :type => 'text', :value => h(params[:author])
          label 'Year', :for => 'start_year'
          input :name => 'start_year', :id => 'start_year', :class => 'year', :type => 'text', :value => h(params[:start_year])
          label 'to', :for => 'end_year'
          input :name => 'end_year', :id => 'end_year', :class => 'year', :type => 'text', :value => h(params[:end_year])
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
    end

  end
end
