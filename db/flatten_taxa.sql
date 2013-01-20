select * from taxa 
	join protonyms on protonyms.id = taxa.protonym_id 
	join citations on citations.id = protonyms.authorship_id 
	join `references` on `references`.id = citations.reference_id
	where name_cache = 'Formicina'
