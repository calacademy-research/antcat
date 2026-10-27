# AntWeb export (`antcat.antweb.txt`)

The nightly file that AntWeb imports as "WorldAnts". It is built on the antcat-export server by
`docker/export_database.sh` (03:00 Pacific), which runs `rake antweb:export`
(`Exporters::Antweb::Exporter`). AntWeb fetches it at 05:00 and loads it with
`SpeciesListUpload.importSpeciesList` (AntWeb repo, `src/org/calacademy/antweb/upload/`).

One row per taxon (all ranks except subtribe and infrasubspecies), tab separated, first line is
the header. Valid taxa come first (rows are sorted by status), so the valid names exist in AntWeb
before the synonyms that point to them. Tabs and line breaks inside values are replaced, so a row
is always one line with 24 columns. The file is written to a temporary file and renamed when
complete; a failed run leaves the previous file.

AntWeb finds columns by header name (lower case, spaces become underscores), not by position.
Do not rename a header without changing AntWeb at the same time.

## Columns

| # | Header | Meaning | How AntWeb uses it |
|---|---|---|---|
| 0 | antcat id | AntCat taxon id | stored; links to AntCat |
| 1-6 | subfamily, tribe, genus, subgenus, species, subspecies | the exported taxon's own classification (`incertae_sedis` when the genus has no subfamily) | builds the AntWeb taxon name: subfamily + genus + " " + species (+ " " + subspecies), lower case |
| 7-10 | author date, author date html, authors, year | authorship | stored and shown |
| 11 | status | AntCat status (valid, synonym, homonym, ...) | decides whether the row is imported and how |
| 12 | available | `TRUE` when the name is nomenclaturally available (see below), else `FALSE` | stored (`taxon.available`), shown as "Available" on taxon and homonym pages; not used in any rule |
| 13 | current valid name | see "Current valid rule" | for synonyms and other statuses that point to a valid name: the row is imported only if this name already exists in AntWeb |
| 14 | original combination | `TRUE` when the taxon is the original combination | stored (authorship parentheses) |
| 15 | was original combination | name of the original combination, if the taxon was recombined | stored |
| 16 | fossil | `TRUE` for fossil taxa | stored, fossil filters |
| 17 | taxonomic history html | history shown on AntWeb taxon pages | stored as the AntCat history description |
| 18-20 | reference id, bioregion, country | protonym details | stored; country and bioregion feed AntWeb's place lists |
| 21 | current valid rank | rank of the exported taxon (the class name, for example `Species`) | decides which rows are imported (family to subspecies) |
| 22 | hol id | Hymenoptera Online id | stored |
| 23 | current valid parent | see "Current valid rule" | stored and shown as "Current Valid Parent" on taxon pages |

### Available (column 12)

Availability is not validity. Junior synonyms, homonyms, unidentifiable names and names excluded
from Formicidae are available (they keep their place in nomenclature) but are not valid.
`FALSE` only when:

- the protonym is a nomen nudum, or
- the status is `unavailable` or `unavailable misspelling`, or
- the taxon is an obsolete combination of a name that is unavailable (its `current_taxon` chain,
  through other obsolete combinations, ends at an unavailable name).

Until 2026-10 this column was `TRUE` only for valid taxa, so every synonym was exported as
not available.

### Current valid rule (columns 13 and 23)

Both columns describe the same taxon: the exported taxon's current valid taxon, found by following
`current_taxon` to the end (`Taxon#now_taxon`; a synonym can point to an obsolete combination or to
another synonym).

- Column 13, current valid name: empty when the taxon has no `current_taxon` (valid, homonym,
  unidentifiable, unavailable, excluded). Otherwise the current valid taxon's subfamily (of that
  taxon, not of the exported one; `incertae_sedis` when it has none), a space, and its full name,
  for example `Formicinae Camponotus foo`. AntWeb removes the space after the subfamily and gets its
  own taxon name (`formicinaecamponotus foo`). For a family or subfamily the name alone
  (`Formicinae`), because that is AntWeb's taxon name for a subfamily.
- Column 23, current valid parent: the parent of that same taxon (of the exported taxon itself when
  it has no `current_taxon`), with subgenera skipped and the parent followed to its own current
  valid taxon. `Formicidae` at the top.

Until 2026-10 column 13 used the exported taxon's subfamily, so a synonym whose valid name is in
another subfamily pointed to a name that AntWeb does not have, and AntWeb skipped the synonym.
Column 23 used the exported taxon's own parent, so for a synonym it showed the old genus.
After the change AntWeb imports those synonyms on its next nightly WorldAnts load.

## Checking a change

The export is tested in `spec/services/exporters/antweb/`. Note that `export_database.sh` resets the
antcat-export checkout to `origin/master` every night, and AntWeb staging and production fetch the
same file. A change to the columns therefore reaches both AntWeb sites the night after it is merged.
To try it on AntWeb staging first, build the file from the branch on antcat-staging
(`bin/rails "antweb:export[/tmp/antcat.antweb.txt]"` inside the app container), load it on AntWeb
staging, and compare the WorldAnts upload report with the previous one before merging.
