module DedupeReferenceSections
  # TODO? make callable from rake task
  def self.dedupe
    ReferenceSection.all.each do |reference_section|
      ReferenceSection.where('references_taxt = ? AND position > ?',
        reference_section.references_taxt, reference_section.position).destroy_all
    end
  end
end