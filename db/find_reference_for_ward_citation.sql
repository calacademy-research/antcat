select wr.authors, wr.year, wr.title, wr.citation, r.authors_string, r.title, r.series_volume_issue, r.pagination, r.citation
  from `references` r
  left join ward_references wr on r.source_reference_id = wr.id
  where r.type = 'UnknownReference'\G
