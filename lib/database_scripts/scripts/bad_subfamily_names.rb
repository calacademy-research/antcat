# Probably not an issue, but I had to test `#sql` with something.
# From https://github.com/calacademy-research/antcat/issues/71

class DatabaseScripts::Scripts::BadSubfamilyNames
  include DatabaseScripts::DatabaseScript

  def results
    sql <<-SQL.squish
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

__END__
description: From %github71.
tags: [regression-test]
