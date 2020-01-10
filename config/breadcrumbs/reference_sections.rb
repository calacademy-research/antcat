# rubocop:disable Layout/IndentationConsistency
crumb :reference_sections do |taxon|
  link "Reference Sections"
  parent taxon
end

  crumb :reference_section do |reference_section|
    if reference_section.persisted?
      link "##{reference_section.id}", reference_section
    else
      link "##{reference_section.id} [deleted]"
    end
    parent :reference_sections, reference_section.taxon
  end

    crumb :edit_reference_section do |reference_section|
      link "Edit"
      parent :reference_section, reference_section
    end

    crumb :reference_section_history do |reference_section|
      link "History"
      parent :reference_section, reference_section
    end

  crumb :new_reference_section do |reference_section|
    link "New"
    parent :reference_sections, reference_section.taxon
  end
# rubocop:enable Layout/IndentationConsistency
