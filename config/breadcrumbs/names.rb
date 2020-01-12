# rubocop:disable Layout/IndentationConsistency
crumb :names do
  link "Names records"
  parent :catalog
end

  crumb :name do |name|
    if name.persisted?
      link "#{name.name_html} (##{name.id})".html_safe, name_path(name)
    else
      link "##{name.id} [deleted]"
    end
    parent :names
  end

    crumb :edit_name do |name|
      link "Edit"
      parent :name, name
    end

    crumb :name_history do |name|
      link "History"
      parent :name, name
    end
# rubocop:enable Layout/IndentationConsistency
