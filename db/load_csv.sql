 truncate table refs;

 load data local infile 'db/ANTBIB_v1R_data.csv'
    into table refs
    character set 'utf8'
    fields terminated by ','
    enclosed by '"'
    lines terminated by '\n'
    (cite_code, authors, year, date, title, citation, notes, possess);

delete from refs where coalesce(authors, '') = '';

select title from refs where title like 'Sobre los cara%';
