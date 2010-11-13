select *
  from ward_references wr
  join `references` r  on r.source_reference_id = wr.id
  join publishers on r.publisher_id = publishers.id
  join places on places.id = publishers.place_id
  where places.name like '%Ufa%'\G
