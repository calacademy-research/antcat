select *
  from author_names a
  join reference_author_names ap on ap.author_name_id = a.id
  join `references` r  on r.id = ap.reference_id
  join ward_references wr  on wr.id = r.source_reference_id
  where a.name = 'St'\G
