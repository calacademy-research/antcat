# I believe this is a database maintenance script that must be called manually.
# Possibly not used any longer.
# TODO? make callable from rake task
# See also `DatabaseScripts::Scripts::DuplicatedReferenceSections`.

module DedupeReferenceSections
  def self.dedupe
    ReferenceSection.all.each do |reference_section|
      ReferenceSection.where('references_taxt = ? AND position > ?',
        reference_section.references_taxt, reference_section.position).destroy_all
    end
  end
end
