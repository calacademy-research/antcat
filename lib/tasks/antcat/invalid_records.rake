# frozen_string_literal: true

require_relative 'invalid_records'

namespace :antcat do
  desc "Find all invalid ActiveRecords (shortcut: `MODELS_TO_CHECK=Journal,author_name rake ac:ir`)"
  task invalid_records: [:environment] do
    AntCat::InvalidRecords.call
  end
end
task 'ac:ir': :'antcat:invalid_records' # Shortcut.
