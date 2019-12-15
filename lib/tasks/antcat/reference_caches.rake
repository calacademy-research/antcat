# Formatted references are cached in the database. Use this to regenerate or invalidate them.

namespace :antcat do
  namespace :reference_caches do
    desc 'Invalidates all reference caches'
    task invalidate: :environment do
      References::Cache::InvalidateAll[]
    end

    desc 'Regenerate all reference caches'
    task regenerate: :environment do
      References::Cache::RegenerateAll[]
    end
  end
end
