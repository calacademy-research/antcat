Rake.application.options.trace = true

namespace :antweb do
  namespace :export do

    desc "Export taxonomy for use by AntWeb"
    task :taxa => :environment do
      Antweb::Exporter.new(true).export
    end

    desc "Compare AntCat's output against AntWeb's"
    task :diff => :environment do
      Antweb::Diff.new(true).diff
    end

  end

end
