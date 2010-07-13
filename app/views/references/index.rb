class Views::References::Index < Erector::Widgets::Page

  include ActionController::UrlWriter

  def head_content
    super
    css 'stylesheets/application.css'
  end

  def page_title
    'ANTBIB'
  end

  def body_content
    div :id => 'container' do
      h3 'ANTBIB'
      table do
        for reference in @references
          tr do
            td do
              text "#{reference.authors} #{reference.year} #{reference.title} #{reference.citation} #{reference.notes}"
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
