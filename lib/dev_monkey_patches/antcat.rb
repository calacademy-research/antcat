# frozen_string_literal: true

module DevMonkeyPatches
  module AntCat
    PRODUCTION_BASE_URL = Settings.production_url
    LOCALHOST_BASE_URL = "http://localhost:3000"

    def self.patch!
      ::Taxon.include Taxon
      ::Protonym.include Protonym
      ::Reference.include Reference
      ::ReferenceSection.include ReferenceSection
    end

    module Taxon
      def dev_dev_link localhost: false, include_name: true
        base_url = localhost ? LOCALHOST_BASE_URL : PRODUCTION_BASE_URL
        link = +"#{base_url}/catalog/#{id}"
        link += "?#{name_cache.tr(' ', '_')}" if include_name

        def link.open
          `xdg-open "#{self}"`
        end

        link
      end
      alias_method :l, :dev_dev_link

      def dev_dev_link_open
        dev_dev_link.open
      end
      alias_method :lo, :dev_dev_link_open

      def dev_dev_link_localhost
        dev_dev_link localhost: true
      end
      alias_method :ll, :dev_dev_link_localhost

      def dev_dev_link_localhost_open
        dev_dev_link_localhost.open
      end
      alias_method :llo, :dev_dev_link_localhost_open
    end

    module Protonym
      def dev_dev_link localhost: false
        base_url = localhost ? LOCALHOST_BASE_URL : PRODUCTION_BASE_URL
        link = +"#{base_url}/protonyms/#{id}"

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
        link = +"#{base_url}/references/#{id}?#{key_with_suffixed_year.tr(' ', '_')}"

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
        link = +"#{base_url}/reference_sections/#{id}/edit"

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
