select citation
  from ward_references wr
  join `references` r  on r.source_reference_id = wr.id
  join author_participations ap on r.id = ap.reference_id
  join authors a on ap.author_id = a.id
  where a.name = ' Alicata, A.'
