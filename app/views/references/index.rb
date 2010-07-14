class Views::References::Index < Erector::Widgets::Page

  include ActionController::UrlWriter

  def head_content
    super
    css 'stylesheets/application.css'
  end

  def page_title
    'ANTBIB'
  end

  def format_reference reference
    "#{italicize(reference.authors)} #{reference.year} #{italicize(reference.title)} #{italicize(reference.citation)} #{italicize(reference.notes)}"
  end

  def italicize s
    s.gsub /\*(.*?)\*/, '<span class=taxon>\1</span>' if s
  end

  def body_content
    div :id => 'container' do
      h3 'ANTBIB'
      table do
        for reference in @references
          tr do
            td do
              rawtext format_reference(reference)
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
