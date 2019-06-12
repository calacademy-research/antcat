# Add additional extensions.
# So in Sass files, look for lines matching: `<optional whitespace> // TODO x`.
SourceAnnotationExtractor::Annotation.class_eval do
  register_extensions("sass")   { |tag| %r{//\s*(#{tag}):?\s*(.*?)$} }
  register_extensions("haml")   { |tag| %r{-#\s*(#{tag}):?\s*(.*?)$} }
  register_extensions("coffee") { |tag| %r{#\s*(#{tag}):?\s*(.*?)$} }
  register_extensions("erb")    { |tag| %r{#\s*(#{tag}):?\s*(.*?)$} }
end

ORIGINAL_NOTES_TAGS = %w[TODO OPTIMIZE FIXME]
CUSTOM_NOTES_TAGS = %w[HACK WIP NOTE PERFORMANCE]
ALL_NOTES_TAGS = ORIGINAL_NOTES_TAGS + CUSTOM_NOTES_TAGS

# Include more tags in addition "TODO|OPTIMIZE|FIXME".
desc "Enumerate all annotations (use notes:todo, :optimize, :fixme, :hack, :wip, :note, :performance)"
task :notes do
  # Clear `rake notes` to avoid listing each annotation twice.
  task(:notes).clear

  tags = ALL_NOTES_TAGS.join("|")
  SourceAnnotationExtractor.enumerate tags, dirs: annotation_dirs, tag: true
end

namespace :notes do
  CUSTOM_NOTES_TAGS.each do |tag|
    task tag.downcase.to_sym do
      SourceAnnotationExtractor.enumerate tag, dirs: annotation_dirs, tag: true
    end
  end
end

def annotation_dirs
  SourceAnnotationExtractor::Annotation.directories + %w[features script spec]
end
