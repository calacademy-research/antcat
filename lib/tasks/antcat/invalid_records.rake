# frozen_string_literal: true

namespace :antcat do
  desc "Find all `!valid?` ActiveRecords"
  task invalid_records: [:environment] do
    Rails.application.eager_load!

    IGNORED_MODELS = [PaperTrail::Version]
    STI_SUBCLASS_MODELS = [Taxon.descendants, Reference.descendants, Name.descendants].flatten
    MODELS_TO_CHECK = ApplicationRecord.descendants - IGNORED_MODELS - STI_SUBCLASS_MODELS

    MODELS_TO_CHECK.each do |model|
      puts "Checking model #{model.name} (#{model.count} records)...".green

      invalid_ids = []
      model.find_each do |record|
        invalid_ids << record.id unless record.valid?
      end

      if invalid_ids.present?
        puts "Invalid #{model.name} records:".red
        puts "#{model.name}.where(id: #{invalid_ids})"
      end
    end
  end
end
