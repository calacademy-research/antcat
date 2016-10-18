# Based on http://crypt.codemancers.com/posts/
# 2013-07-12-redefine-rake-routes-to-add-your-own-custom-tag-in-Rails/

task(:notes).clear

# Clear all subtasks to avoid listing each annotation twice.
namespace :notes do
  annotations = [:optimize, :fixme, :todo, :hack, :wip]
  annotations.each { |annotation| task(annotation).clear }
end

desc "Enumerate all annotations (use notes:optimize, :fixme, :todo, :hack or :wip)"
task :notes do
  SourceAnnotationExtractor.enumerate "OPTIMIZE|FIXME|TODO|HACK|WIP", tag: true
end

namespace :notes do
  task :wip do
    SourceAnnotationExtractor.enumerate "WIP", tag: true
  end
  task :hack do
    SourceAnnotationExtractor.enumerate "WIP", tag: true
  end
end
