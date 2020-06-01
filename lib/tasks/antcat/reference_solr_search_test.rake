# frozen_string_literal: true

namespace :antcat do
  desc "Find references that are not in the Solr results of their author_names_string_cache"
  task reference_solr_search_test: [:environment] do
    puts "Checking author_names_string_cache + year...".blue

    progress = ProgressBar.create(
      total: Reference.count,
      format: "%a %e %P% Processed: %c from %C",
      throttle_rate: 0.5
    )

    Reference.find_each do |reference|
      in_results = References::FulltextSearchQuery.new(
        freetext: reference.author_names_string_cache,
        year: reference.year
      ).call.map(&:id).include?(reference.id)

      puts "Could not find #{reference.id}: #{reference.author_names_string_cache}".red unless in_results
      progress.increment
    end

    puts "Done.".blue
  end
end
