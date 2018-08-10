namespace :antcat do
  namespace :references do
    desc 'Check URLs'
    task check_urls: :environment do
      references_with_documents = Reference.joins(:document)
      progress = Progress.create total: references_with_documents.count
      error_count = 0

      references_with_documents.find_each do |reference|
        progress.increment
        next unless reference.document.send(:hosted_by_us?)
        begin
          reference.document.actual_url
        rescue Exception => e # rubocop:disable Lint/RescueException
          puts e.inspect
          puts "#{reference.id} #{reference.document.id} #{reference.document.url}"
          error_count += 1
        end
      end

      puts "#{references_with_documents.count} with documents"
      puts "#{error_count} of those with documents, not found"
    end

    # Formatted references are cached (stored in the database).
    # Use this to regenerate all such caches, or to invalidate them (they will be
    # regenerated next time they are shown on the site).
    namespace :caches do
      namespace :invalidate do
        desc 'Invalidates all reference caches'
        task all: :environment do
          References::Cache::InvalidateAll[]
        end
      end

      namespace :regenerate do
        desc 'Regenerate all reference caches'
        task all: :environment do
          References::Cache::RegenerateAll[]
        end
      end
    end
  end
end
