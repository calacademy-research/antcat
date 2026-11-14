# AntCat data model

Every table of `db/schema.rb` (30 on 2026-11-13), what one row is, and how the tables hang together.
`spec/catalog/data_model_spec.rb` fails when a table of the schema has no section here, or a section names a table
that is not in the schema. Columns are listed only where they carry meaning that is not obvious from their name; the
full list is in `db/schema.rb`.

Words used below:

- **taxt**: text with tags that point at other records, for example `{tax 429011}` (a taxon), `{pro 1234}` (a
  protonym) or `{ref 1234}` (a reference); the tags are in `app/models/taxt.rb`. Columns ending in `_taxt` hold it. It is turned into links when shown (`app/services/taxt`), and "What
  links here" finds every taxt that points at a record.
- **STI** (single table inheritance): one table for several Ruby classes; the `type` column says which.
- **paper_trail**: every change to a row of a table marked "history: yes" writes a row of `versions` (who, when, the
  old values and the changes). That is the revision history on the site.

## How the tables connect

```
             names ─┐                         ┌─ citations ── references ── reference_author_names ── author_names ── authors
                    │                         │                    │                                                   │
taxa ── protonym_id ┴─> protonyms ── authorship_id                 ├─ journals, publishers                             users
  │                         │                                      ├─ reference_documents (the PDF or link)
  │                         ├─ history_items (taxonomic history, ordered; point at references, protonyms, taxa)
  │                         └─ type_name_id ─> type_names (type taxon of a genus-group name, with its reference)
  ├─ current_taxon_id ─> taxa (the valid taxon of a synonym or an obsolete combination)
  ├─ subfamily_id, tribe_id, genus_id, subgenus_id, species_id ─> taxa (the parents)
  └─ reference_sections (sections of references on a taxon page)
```

A **taxon** is a name as used in the catalog (valid or not). A **protonym** is that name as first published: who
described it, where and when, the type material and locality. Several taxa share one protonym (the original
combination, later combinations, a synonym); the history of a name is kept on the protonym and shown on each of
its taxa.

## Taxonomy

### `taxa`

One row per taxon: every name of the catalog in one rank and status. STI by rank: `type` is `Family`,
`Subfamily`, `Tribe`, `Subtribe`, `Genus`, `Subgenus`, `Species`, `Subspecies` or `Infrasubspecies`
(`app/models/taxon_sti_subclasses`).

- `status`: `valid`, `synonym`, `homonym`, `unidentifiable`, `unavailable`, `excluded from Formicidae`,
  `obsolete combination`, `unavailable misspelling` (`app/models/status.rb`).
- `current_taxon_id`: for a synonym, an obsolete combination or a misspelling, the taxon now used.
  `homonym_replaced_by_id`: for a homonym, its replacement name.
- `family_id`, `subfamily_id`, `tribe_id`, `genus_id`, `subgenus_id`, `species_id`, `subspecies_id`: the parents
  (only the ones that apply to the rank). `incertae_sedis_in`: the rank in which the placement is uncertain.
- `protonym_id` (required), `name_id` (required) and `name_cache` (the name as text, for sorting and the export).
- `original_combination`: this taxon is the name in its original genus. `unresolved_homonym`, `collective_group_name`.
- `hol_id`: the taxon's number in Hymenoptera Online.
- Searched through Solr. History: yes. Exported to AntWeb (all ranks but subtribe and infrasubspecies).

### `protonyms`

One row per original description of a name.

- `authorship_id` -> `citations` (the reference and pages of the description), `name_id` -> `names` (the name as
  published), `type_name_id` -> `type_names`.
- `locality`, `bioregion` (of the type material), `primary_type_information_taxt`, `secondary_type_information_taxt`,
  `type_notes_taxt`, `forms` (castes described), `etymology_taxt`, `notes_taxt`.
- Flags: `fossil`, `sic` (spelled as in the original), `nomen_nudum`, `ichnotaxon`; `gender_agreement_type`.
- Searched through Solr. History: yes.

### `names`

One row per name string. STI by kind and rank (`app/models/name_sti_subclasses`: family-group, genus-group and
species-group names, for example `SpeciesName`). `name` (the full name), `epithet` (the last word),
`cleaned_name` (without the subgenus and other marks), `gender`, `non_conforming`. Used by `taxa` and `protonyms`.
History: yes.

### `history_items`

The taxonomic history of a protonym, one statement per row, in `position` order: "combination in X", "junior
synonym of Y", "status as species", and so on. `type` is the kind of statement (`History::Definitions::TYPES`);
`subtype`, `picked_value`, `text_value` its details; `reference_id` and `pages` its source (`citation_note`: a note printed right after the citation); `object_protonym_id`
or `object_taxon_id` the other name it is about; `taxt` for statements written as text; `rank` when the statement
is shown only on the taxon of one rank. History: yes.

### `citations`

A reference and pages: the authorship of a protonym (`protonyms.authorship_id`). History: yes.

### `type_names`

The type taxon of a genus-group name (the type species of a genus, for example): `taxon_id`, `fixation_method`,
and the reference and pages where it was fixed. History: yes.

### `reference_sections`

The sections of references shown on a taxon page (title, subtitle and the references, all taxt), in `position`
order. History: yes.

### `institutions`

Museums and collections that hold type material: `abbreviation` (as in the type information, for example `MCZC`),
`name`, `grscicoll_identifier` (the GRSciColl record). History: yes.

## References

### `references`

One row per publication. STI: `ArticleReference` (with `journal_id` and `series_volume_issue`), `BookReference`
(with `publisher_id`), `NestedReference` (a chapter: `nesting_reference_id` -> the book).

- `year`, `stated_year`, `year_suffix` (2001a), `date`, `online_early`, `pagination`, `title`, `doi`.
- `bolton_key`, `normalized_bolton_key`: the key of the reference in Barry Bolton's catalog.
- `review_state`: the editors' review: `none`, `reviewing`, `reviewed`.
- `editor_notes`, `public_notes`, `taxonomic_notes`.
- Columns ending in `_cache` are made from other rows (the author string, the formatted reference) and rebuilt when
  those change.
- Searched through Solr. History: yes (without the cache columns).

### `reference_author_names`

The authors of a reference in order: `reference_id`, `author_name_id`, `position`. History: yes.

### `author_names`

One spelling of an author's name, as it appears on references (`name`), belonging to one `authors` row.
History: yes.

### `authors`

One row per person who wrote references. Holds no columns of its own: the spellings are `author_names`; a user of
the site can be linked to an author (`users.author_id`). History: yes.

### `journals`

Journal names, for article references. History: yes.

### `publishers`

Publisher name and place, for book references. History: yes.

### `reference_documents`

The PDF of a reference: an uploaded file (`file_file_name`; the file is on Amazon S3 under `<id>/<file name>`) or
a link to it (`url`). History: yes.

## Editing record

### `versions`

The revision history (paper_trail): one row per change of a row in a table with history. `item_type` and `item_id`
(the row), `event` (create, update, destroy), `whodunnit` (the user id), `object` (the row before), `object_changes`,
`request_uuid` (groups the changes of one save). Written by the app, never edited.

### `activities`

The activity feed (`/activities`): one row per edit or event, for example a reference added or a taxon moved. `trackable_type` and `trackable_id` (the record), `user_id`, `event`, `edit_summary`, `parameters`,
`automated_edit` (made by a script), `request_uuid` (the same as in `versions`). History: yes.

## People and site

### `users`

The accounts. Devise columns (email, encrypted password, sign-in times and addresses, reset token). Rights:
`helper`, `editor`, `superadmin`, `developer` (true or false each); `locked`, `deleted`, `hidden`;
`enable_email_notifications`; `author_id` (the user as an author of references). History: yes, without the
sign-in times and addresses and the password (`SKIP_PAPER_TRAIL_COLUMNS`).

### `comments`

Comments on an issue, a feedback message or a site notice (`commentable_type`, `commentable_id`), by a user.
History: yes.

### `notifications`

Tells a user that something concerns them (a reply, a mention): `user_id` (who is told), `notifier_id` (who caused
it), `attached_type` and `attached_id`, `reason`, `seen`. An email goes out when the user allows it.

### `feedbacks`

Messages sent with the feedback form: `comment`, `name`, `email`, `user_id` (when signed in), `ip`, `page`, `open`.
History: yes.

### `issues`

The editors' list of things to fix: `title`, `description`, `user_id`, `closer_id`, `open`, `help_wanted`.
History: yes.

### `site_notices`

Notices to editors shown at the top of the site, with who has read them (`read_marks`). History: yes.

### `read_marks`

Which user has read which site notice (the `unread` gem): `readable_type` and `readable_id`, `reader_id`,
`timestamp`.

### `wiki_pages`

The help pages of the site (`title`, `content` in Markdown, `permanent_identifier` for pages the code links to,
`featured`). History: yes.

### `tooltips`

Help texts shown next to form fields: `key`, `scope`, `text`. History: yes.

### `settings`

Per-user settings (the `ledermann-rails-settings` gem): `var` (the group; today only `editing_helpers`), `value`,
`target_type` and `target_id` (the user).

## API

### `api_keys`

One row per registration of a free API key (`app/models/api_key.rb`): who (`name`, `email`, `institution`,
`project`), `level` (`registered`, `collaborator`, `admin`), `status` (`pending`, `active`, `revoked`), the key and the confirmation link stored only as SHA-256
digests (`key_digest`, `confirmation_digest`) with the first characters of the key (`key_prefix`), the dates of each
step, `last_used_at`, and limits of its own when a superadmin sets them (`requests_per_minute`, `requests_per_day`,
`records_per_page`, `records_per_day`).

### `api_usage_days`

API requests, records sent and refused requests per UTC day: one row per key, and one per hashed visitor address
for requests without a key (`api_key_id` 0, `client` the hash).

### `api_usage_minutes`

API requests per minute, for the per-minute limits. Old rows are pruned.
