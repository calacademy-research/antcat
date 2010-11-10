--select wr.authors, wr.citation
 --from ward_references wr
  --join `references` r  on r.source_reference_id = wr.id
  --join author_participations ap on r.id = ap.reference_id
  --join authors a on ap.author_id = a.id
  --where a.id = 140718\G

select *
  from author_participations ap
  join `references` r  on r.id = ap.reference_id
  join ward_references wr  on wr.id = r.source_reference_id
  where ap.author_id = 140718\G
