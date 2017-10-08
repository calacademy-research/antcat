namespace :antcat do
  namespace :references do
    # TODO move most code to somewhere else and call it from here.
    desc 'Check URLs'
    task check_urls: :environment do
      progress = Progress.create total: Reference.count
      references_with_documents_count = error_count = 0

      Reference.find_each do |reference|
        progress.increment
        next unless reference.document && reference.document.send(:hosted_by_us?)
        references_with_documents_count += 1
        begin
          reference.document.actual_url
        rescue Exception => e
          puts e.inspect
          puts "#{reference.id} #{reference.document.id} #{reference.document.url}"
          error_count += 1
        end
      end

      puts "#{references_with_documents_count} with documents"
      puts "#{error_count} of those with documents, not found"
    end

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
