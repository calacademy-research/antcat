
class Views::References::Index < Views::Base

  def head_content
    super
    javascript_include_tag 'reference_form'
  end

  def container_content
    div {widget Views::Search.new}
    hr

    unless @references.present?
      rawtext 'No results found'
    else
      table :class => 'references' do
        for reference in @references
          tr {td {widget Views::References::Reference.new :reference => reference}}
        end
      end
    end

    div {rawtext will_paginate @references}

    widget Views::References::Reference.new :class => 'reference_template'
  end
end
