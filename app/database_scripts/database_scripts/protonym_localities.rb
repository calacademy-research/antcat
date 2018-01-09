module DatabaseScripts
  class ProtonymLocalities < DatabaseScript
    def results
      Protonym.distinct.pluck(:locality).reject(&:blank?).sort
    end

    def render
      markdown "\n\n* #{results.join("\n* ")}"
    end
  end
end

__END__
description: >
  This script is just lists of all unique protonym `locality`s. See %github207.
topic_areas: [types]
