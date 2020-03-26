# frozen_string_literal: true

module DevMonkeyPatches
  module AntCat
    PRODUCTION_BASE_URL = "https://antcat.org/"
    LOCALHOST_BASE_URL = "localhost:3000/"

    def self.patch!
      ::Taxon.include Taxon
      ::Reference.include Reference
      ::ReferenceSection.include ReferenceSection
    end

    module Taxon
      def dev_dev_link localhost: false
        base_url = localhost ? LOCALHOST_BASE_URL : PRODUCTION_BASE_URL
        link = "#{base_url}/catalog/#{id}?#{name_cache.tr(' ', '_')}"
        def link.open
          `xdg-open "#{self}"`
        end
        link
      end
      alias_method :l, :dev_dev_link

      def dev_dev_link_localhost
        dev_dev_link localhost: true
      end
      alias_method :ll, :dev_dev_link_localhost
    end

    module Reference
      def dev_dev_link localhost: false
        base_url = localhost ? LOCALHOST_BASE_URL : PRODUCTION_BASE_URL
        link = "#{base_url}/references/#{id}?#{keey.tr(' ', '_')}"
        def link.open
          `xdg-open "#{self}"`
        end
        link
      end
      alias_method :l, :dev_dev_link

      def dev_dev_link_localhost
        dev_dev_link localhost: true
      end
      alias_method :ll, :dev_dev_link_localhost
    end

    module ReferenceSection
      def dev_dev_link localhost: false
        base_url = localhost ? LOCALHOST_BASE_URL : PRODUCTION_BASE_URL
        link = "#{base_url}/reference_sections/#{id}/edit"
        def link.open
          `xdg-open "#{self}"`
        end
        link
      end
      alias_method :l, :dev_dev_link

      def dev_dev_link_localhost
        dev_dev_link localhost: true
      end
      alias_method :ll, :dev_dev_link_localhost
    end
  end
end
