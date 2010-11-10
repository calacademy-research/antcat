select *
  from authors a
  join author_participations ap on ap.author_id = a.id
  join `references` r  on r.id = ap.reference_id
  join ward_references wr  on wr.id = r.source_reference_id
  where a.name = 'St'\G
