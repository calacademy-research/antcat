select * from taxa join protonyms on taxa.protonym_id = protonyms.id join citations on protonyms.authorship_id = citations.id WHERE citations.id = 155089
