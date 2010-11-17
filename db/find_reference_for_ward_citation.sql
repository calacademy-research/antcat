select wr.authors, wr.year, wr.title, wr.citation, r.authors_string, j.name, r.series_volume_issue, r.pagination
  from ward_references wr
  join `references` r
  on wr.reference_id = r.id
  left join journals j on j.id = r.journal_id
  where j.name like '%in Innsbr%'\G
