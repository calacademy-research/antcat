# frozen_string_literal: true

module DevMonkeyPatches
  module Object
    def self.patch!
      ::Object.include self
    end

    STATUSES = [
      VA =  Status::VALID,
      SY =  Status::SYNONYM,
      HO =  Status::HOMONYM,
      UNI = Status::UNIDENTIFIABLE,
      UNA = Status::UNAVAILABLE,
      EFF = Status::EXCLUDED_FROM_FORMICIDAE,
      OC =  Status::OBSOLETE_COMBINATION,
      UM =  Status::UNAVAILABLE_MISSPELLING
    ]

    # Find taxon by name or id.
    def dev_dev_taxon name_or_id
      return Taxon.find(name_or_id) if name_or_id.is_a? Numeric

      matches = Taxon.where(name_cache: name_or_id)
      case matches.size
      when 0 then nil
      when 1 then matches.first
      else
        $stdout.puts "returned more than one match.".red
        matches
      end
    end
    alias_method :ddt, :dev_dev_taxon

    # Puts to standard out (not suppressed by RSpec/Capybara).
    def dev_dev_puts string
      $stdout.puts string
    end
    alias_method :ddp, :dev_dev_puts

    # Prefix: p
    # "ddpg" = "dd puts green"
    # "ddpgl" = "dd puts green light"
    # Puts to standard out with color.
    %w[red green yellow blue magenta cyan white].each do |color|
      color_method_name = "ddp#{color.to_s.first}".to_sym
      define_method color_method_name do |string|
        $stdout.puts string.to_s.public_send color
      end

      light_color_method_name = "#{color_method_name}l".to_sym
      define_method light_color_method_name do |string|
        $stdout.puts string.to_s.public_send "light_#{color}"
      end
    end

    def dd_ap
      AwesomePrint.irb!
    end

    # Log/not SQL queries in the console.
    def dd_no_log
      ActiveRecord::Base.logger = nil
    end

    def dd_log_much
      ActiveRecord::Base.logger = Logger.new STDOUT
    end
  end
end
