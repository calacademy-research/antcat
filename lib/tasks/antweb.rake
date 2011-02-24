Rake.application.options.trace = true

namespace :antweb do
  namespace :export do

    desc "Export taxonomy for use by AntWeb"
    task :taxa => :environment do
      Antweb::Exporter.new(true).export 'data/output'
    end

    desc "Compare AntCat's output against AntWeb's"
    task :diff => :environment do
      Antweb::Diff.new(true).diff_files 'data/output', 'data/antweb/2010-06'
    end

  end

end
