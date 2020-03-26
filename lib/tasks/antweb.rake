# frozen_string_literal: true

namespace :antweb do
  DEFAULT_EXPORT_FILENAME = 'data/output/antcat.antweb.txt'

  desc "Export taxonomy"
  task :export, [:filename] => :environment do |_task, args|
    filename = args[:filename] || DEFAULT_EXPORT_FILENAME
    Exporters::Antweb::Exporter[filename]
  end
end
