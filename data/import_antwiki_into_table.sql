TRUNCATE TABLE antwiki_valid_taxa;
-- create this file by saving in Excel as Tab-Delimited Text (not the apparent default of UTF-16)
LOAD DATA LOCAL INFILE '/Users/mwilden/antcat/data/antwiki/AntWiki_Valid_Species.txt' REPLACE INTO TABLE antwiki_valid_taxa FIELDS TERMINATED BY '\t' LINES TERMINATED BY '\r' IGNORE 1 LINES;
SELECT * FROM antwiki_valid_taxa;
