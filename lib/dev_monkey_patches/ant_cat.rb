module DevMonkeyPatches
  module AntCat
    def self.patch!
      ::Taxon.include Taxon
      ::Reference.include Reference
      ::ReferenceSection.include ReferenceSection
    end

    module Taxon
      def dev_dev_link localhost: false
        host = localhost ? "localhost:3000" : "antcat.org"
        link = "http://#{host}/catalog/#{id}?#{name_cache.tr(' ', '_')}"
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
        host = localhost ? "localhost:3000" : "antcat.org"
        link = "http://#{host}/references/#{id}?#{keey.tr(' ', '_')}"
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
        host = localhost ? "localhost:3000" : "antcat.org"
        link = "http://#{host}/reference_sections/#{id}/edit"
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
