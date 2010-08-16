
class Views::References::Index < Views::Base

  def head_content
    super
    javascript_include_tag 'reference_form'
  end

  def container_content
    div {widget Views::Search.new}
    hr

    rawtext 'No results found' unless @references.present?

    p {a "Add reference", :href => '#', :class => 'add_reference_link'} if @references.empty?

    table :class => 'references' do
      for reference in @references
        tr {td {widget Views::References::Reference.new :reference => reference}}
      end
      tr(:class => 'reference_template_row') {td {widget Views::References::Reference.new :class => 'reference_template'}}
    end

    div {rawtext will_paginate @references}

  end
end
