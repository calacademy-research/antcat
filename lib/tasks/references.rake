namespace :antcat do
  namespace :references do
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
