# rubocop:disable Layout/IndentationConsistency
crumb :reference_sections do |taxon|
  link "Reference Sections"
  parent taxon
end

  crumb :reference_section do |reference_section|
    link "##{reference_section.id}", reference_section
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
