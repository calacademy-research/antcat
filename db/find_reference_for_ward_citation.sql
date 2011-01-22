select
  wr.id, wr.authors, wr.year, wr.title, wr.citation,
  r.type, r.author_names_string_cache, r.title, r.series_volume_issue, r.pagination, r.citation,
  j.name
  from `references` r
  left join journals j on j.id = r.journal_id
  left join ward_references wr on r.source_reference_id = wr.id
  where wr.citation like '%Andre, Edm%'\G
