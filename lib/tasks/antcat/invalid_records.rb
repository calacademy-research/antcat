# frozen_string_literal: true

module AntCat
  class InvalidRecords
    def self.call
      new.call
    end

    def initialize
      @start_time = Time.current
    end

    def call
      models_to_check.sort_by(&:name).each do |model|
        puts "Checking model #{model.name} (#{model.count} records)...".green

        check_model model

        puts
      end

      puts
      puts "Finished in #{(Time.current - start_time).seconds} s".blue
    end

    private

      attr_reader :start_time

      def models_to_check
        if ENV['MODELS_TO_CHECK']
          return ENV['MODELS_TO_CHECK'].split(',').map(&:classify).map(&:constantize)
        end

        Zeitwerk::Loader.eager_load_all # For STI subclasses.

        ignored_models = [PaperTrail::Version, Activity]
        sti_subclass_models = [Taxon.descendants, Reference.descendants, Name.descendants].flatten

        ApplicationRecord.descendants - ignored_models - sti_subclass_models
      end

      def check_model model
        progress = create_progress_bar(model.count)

        invalid_ids = []
        model.find_each do |record|
          progress.increment
          invalid_ids << record.id unless record.valid?
        end

        if invalid_ids.present?
          puts "Invalid #{model.name} records:".red
          puts "#{model.name}.where(id: #{invalid_ids})"
          puts
        end
      end

      def create_progress_bar total
        ProgressBar.create(total: total, format: "%a %e %P% Processed: %c from %C %B")
      end
  end
end
