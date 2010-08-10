
class Views::References::Index < Views::Base

  include ActionController::UrlWriter

  def container_content
    div do
      widget Views::Search.new
    end

    hr

    unless @references.present?
      rawtext 'No results found'
    else
      table :class => 'references' do
        for reference in @references
          tr { td do
            div :id => "reference_#{reference.id}", :class => 'reference' do
              widget Views::References::Reference.new :reference => reference
            end
          end }
        end
      end
    end

    div { rawtext will_paginate @references }
    p
    rawtext link_to "New Reference", new_reference_path
  end
end
