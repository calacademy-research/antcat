Rake.application.options.trace = true

namespace :antweb do

  desc "Export taxonomy"
  task :export => :environment do
    Antweb::Exporter.new(true).export 'data/output'
  end

  desc "Compare AntCat's output against AntWeb's"
  task :diff => :environment do
    Antweb::Diff.new(true).diff_files 'data/output', 'data/antweb/2010-07'
  end

  desc "Export and diff AntWeb output"
  task :export_and_diff => [:export, :diff]

end
