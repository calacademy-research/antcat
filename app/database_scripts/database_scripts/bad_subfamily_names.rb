# From https://github.com/calacademy-research/antcat/issues/71

module DatabaseScripts
  class BadSubfamilyNames < DatabaseScript
    def results
      ActiveRecord::Base.connection.exec_query <<-SQL.squish
        SELECT COUNT(*) FROM taxa t
          JOIN taxa t2 ON ((t.type = 'Species' OR t.type = 'Subspecies') AND t.genus_id = t2.id)
          WHERE t.subfamily_id != t2.subfamily_id
          OR (t.subfamily_id IS NOT NULL AND t2.subfamily_id IS NULL);
      SQL
    end

    def no_database_issues_on_on
      '[{"COUNT(*)":0}]'
    end
  end
end

__END__
description: From %github71.
tags: [regression-test]
topic_areas: [catalog]
