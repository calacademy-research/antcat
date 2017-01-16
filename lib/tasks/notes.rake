# Add additional extensions.
# So in Sass files, look for lines matching: `<optional whitespace> // TODO x`.
SourceAnnotationExtractor::Annotation.class_eval do
  register_extensions("sass")   { |tag| %r(//\s*(#{tag}):?\s*(.*?)$) }
  register_extensions("haml")   { |tag| %r(-#\s*(#{tag}):?\s*(.*?)$) }
  register_extensions("coffee") { |tag| %r(#\s*(#{tag}):?\s*(.*?)$) }
  register_extensions("erb")    { |tag| %r(#\s*(#{tag}):?\s*(.*?)$) }
end

# Include more tags in addition "TODO|OPTIMIZE|FIXME".
desc "Enumerate all annotations (use notes:optimize, :fixme, :todo, :hack or :wip)"
task :notes do
  # Clear `rake notes` to avoid listing each annotation twice.
  task(:notes).clear

  tags = "OPTIMIZE|FIXME|TODO|HACK|WIP"
  SourceAnnotationExtractor.enumerate tags, dirs: annotation_dirs, tag: true
end

namespace :notes do
  task :wip do
    SourceAnnotationExtractor.enumerate "WIP", dirs: annotation_dirs, tag: true
  end
  task :hack do
    SourceAnnotationExtractor.enumerate "WIP", dirs: annotation_dirs, tag: true
  end
end

def annotation_dirs
  SourceAnnotationExtractor::Annotation.directories + %w(features script spec)
end
