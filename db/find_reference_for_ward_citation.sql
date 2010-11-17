select wr.citation, j.name, r.series_volume_issue, r.pagination
  from ward_references wr
  join `references` r
  on wr.reference_id = r.id
  left join journals j on j.id = r.journal_id
  where wr.citation like '%6(1)(2%'\G
