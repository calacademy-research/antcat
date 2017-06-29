class DatabaseScripts::Scripts::ProtonymLocalities
  include DatabaseScripts::DatabaseScript

  def results
    Protonym.uniq.pluck(:locality).reject(&:blank?).sort
  end

  def render
    markdown "\n\n* #{results.join("\n* ")}"
  end
end

__END__
description: >
  This script is just lists of all unique protonym `locality`s. See %github207.
tags: [new!]
topic_areas: [types]
