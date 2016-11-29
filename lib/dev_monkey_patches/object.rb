module DevMonkeyPatches::Object
  def self.patch!
    ::Object.include self
  end

  def dev_dev_mixed_in?
    true
  end

  def self.dev_dev_define_send_field_to_klass_as field, klass, method_name
    define_method(method_name) { klass.send field }
  end

  # Find taxon by name or id.
  def dev_dev_taxon name_or_id
    return Taxon.find(name_or_id) if name_or_id.kind_of? Numeric

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
  # "ddpr" = "dd puts red"
  # Puts to standard out with color.
  %w(green red blue yellow).each do |color|
    method = "ddp#{color.to_s.first}".to_sym
    define_method method do |string|
      $stdout.puts "#{string}".send color
    end
  end

  def dev_dev_random_in_model model
    offset = rand(model.count)
    model.offset(offset).first
  end

  # Prefixes: f, l and r
  # "ddlar" = "dd last article reference"
  # First, last and random of type.
  type_and_alias = {
    Taxon            => :t,
    Family           => :f,
    Subfamily        => :sf,
    Tribe            => :tr,
    Genus            => :g,
    Subgenus         => :sg,
    Species          => :s,
    Subspecies       => :ss,

    Reference        => :r,
    ArticleReference => :ar,
    BookReference    => :br,
    UnknownReference => :ur,
    MissingReference => :mr
  }.tap { |h| raise "prefix not uniqe" unless h.to_set.size == h.values.uniq.size }

  type_and_alias.each do |type, short_alias|
    # First of type.
    dev_dev_define_send_field_to_klass_as :first, type, "ddf#{short_alias}".to_sym

    # Last of type.
    dev_dev_define_send_field_to_klass_as :last, type, "ddl#{short_alias}".to_sym

    # Random of type.
    define_method "ddr#{short_alias}".to_sym do
      dev_dev_random_in_model type
    end
  end

  # Log/not SQL queries in the console.
  def dd_no_log
    ActiveRecord::Base.logger = nil
  end

  def dd_log_much
    ActiveRecord::Base.logger = Logger.new STDOUT
  end
end
