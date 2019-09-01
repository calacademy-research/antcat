# rubocop:disable Rails/TimeZone
class DeferredGarbageCollection
  DEFERRED_GC_THRESHOLD = (ENV['DEFER_GC'] || 10.0).to_f

  @@last_gc_run = Time.now # rubocop:disable Style/ClassVars

  def self.start
    GC.disable if DEFERRED_GC_THRESHOLD > 0
  end

  def self.reconsider
    return unless DEFERRED_GC_THRESHOLD > 0 && Time.now - @@last_gc_run >= DEFERRED_GC_THRESHOLD

    GC.enable
    GC.start
    GC.disable
    @@last_gc_run = Time.now # rubocop:disable Style/ClassVars
  end
end
# rubocop:enable Rails/TimeZone
