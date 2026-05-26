# KDES Seminar — notes for Claude

See `README.md` for the full add-meeting workflow, and
`email_templates.md` for speaker invitation / coordination email drafts. Notes below are caveats not
covered there.

## `add_abstracts.py` adds duplicates when re-run

The script does not check whether a `<li>` already has a `<details>` block
following it — it adds one for every `<li><b>...</b>` whose title matches an
abstract. Running it a second time (or running it after a year file already
has abstracts) adds another copy of every matching abstract.

When adding a new meeting:
- Edit `meetings_raw.txt` and the year HTML file by hand for the new entries
  only.
- If you run `add_abstracts.py`, diff the year file afterward and remove any
  duplicate `<details>` it created on previously-injected entries.
- Safer alternative: paste the `<details>` block manually into the year HTML
  and skip the script.

## Asking the user for missing info

Before editing, confirm:
- Meeting date (the user often gives a talk without one).
- For each speaker: title, institution. Use `TBD` for an unknown title only
  after the user confirms.
- Watch name order — don't assume Western given/family ordering for
  Chinese/Korean names.

## Date formats

- Year HTML (`<span class="section">`): `YYYY-MM-DD`
- `meetings_raw.txt` header: `YYYY. M. D at HH:MM  Day / *#ROOM* or Zoom`
- Meeting numbers increment by one; check the most recent block in
  `meetings_raw.txt` for the next number.
