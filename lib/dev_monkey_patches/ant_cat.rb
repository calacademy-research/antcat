module DevMonkeyPatches::AntCat
  def self.patch!
    ::Taxon.include Taxon
  end

  module Taxon
    def sf
      subfamilies
    end

    def g
      genera
    end

    def s
      species
    end

    def ss
      subspecies
    end

    def ch
      children
    end

    def dev_dev_link localhost: false
      host = localhost ? "localhost:3000" : "antcat.org"
      link = "http://#{host}/catalog/#{id}?#{name_cache.tr(" ", "_")}"
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
