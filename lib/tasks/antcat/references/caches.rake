# frozen_string_literal: true

require_relative 'caches'

# Formatted references and keys are cached in the database. Use this to regenerate or invalidate them.

namespace :antcat do
  namespace :references do
    desc 'Invalidate all reference content caches'
    task invalidate_content_caches: :environment do
      AntCat::Caches.new.invalidate_content_caches
    end

    desc 'Regenerate all reference content caches'
    task regenerate_content_caches: :environment do
      AntCat::Caches.new.regenerate_content_caches
    end

    desc 'Check all reference content caches'
    task check_content_caches: :environment do
      AntCat::Caches.new.check_content_caches
    end

    desc 'Regenerate all reference key caches'
    task regenerate_key_caches: :environment do
      AntCat::Caches.new.regenerate_key_caches
    end

    desc 'Check all reference key caches'
    task check_key_caches: :environment do
      AntCat::Caches.new.check_key_caches
    end
  end
end
