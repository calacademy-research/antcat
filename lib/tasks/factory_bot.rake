# frozen_string_literal: true

namespace :factory_bot do
  desc "Verify that all FactoryBot factories are valid"
  task lint: :environment do
    require 'sunspot_test'
    SunspotTest.stub

    ABSTRACT_FACTORIES = [:taxon, :reference, :name]

    if Rails.env.test?
      factories_to_lint = FactoryBot.factories.reject do |factory|
        factory.name.in?(ABSTRACT_FACTORIES)
      end

      conn = ActiveRecord::Base.connection
      conn.transaction do
        if ENV['LINT_TRAITS']
          FactoryBot.lint factories_to_lint, traits: true
        else
          puts "use LINT_TRAITS=y to also lint traits"
          FactoryBot.lint factories_to_lint
        end
        raise ActiveRecord::Rollback
      end
    else
      system "RAILS_ENV=test bundle exec rake factory_bot:lint"
    end
  end
end
