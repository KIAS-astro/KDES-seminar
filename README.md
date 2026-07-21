# KDES Seminar Website

## Structure

- `index.html` — frameset (menu + content)
- `menu.html` — top navigation bar
- `main.php` — includes all year HTML files; also has the "Expand All Abstracts" button
- `20XX.html` — one file per year, lists meetings by date with talk titles, speakers, and abstracts
- `style.css` — shared styles including abstract display

Requires a PHP server to run. To preview locally:
```
php -S localhost:8000
```
Then open `http://localhost:8000`.

## Adding a New Meeting

### 1. Update the year HTML file (e.g. `2026.html`)

Add a new section at the top of the file (before the previous entry), following this template:

```html
<span class="section">YYYY-MM-DD</span>
<ul class="square">
<li><b>Talk Title</b> (Speaker Name, Institution)
<li><b>Talk Title 2</b> (Speaker Name 2, Institution 2)
</ul>
```

### 2. Add the abstract(s) to `meetings_raw.txt`

Append a new meeting block at the top of `meetings_raw.txt`, following the existing format:

```
=============================================
<< KIAS Dark Energy Science Group Meeting NNNth >>
YYYY. M. D at HH:MM  Day / #ROOM or Zoom  ( https://zoom.us/j/4316792441 )

1. Talk Title (Speaker Name, Institution)

Abstract: Abstract text here...

2. Talk Title 2 (Speaker Name 2, Institution 2)

Abstract: Abstract text here...

```

If a talk has no abstract, simply omit the `Abstract:` line.

### 3. Run the abstract injection script

```
python3 add_abstracts.py
```

This will inject `<details>/<summary>` blocks for any talks that now have a matching abstract but don't yet have one in the HTML.

### 4. Commit and deploy

```
git add 20XX.html meetings_raw.txt
git commit -m "Add NNNth meeting (YYYY-MM-DD)"
```

Then deploy the year's file to the PHP server:

```
./deploy.sh 2026
```

This copies `YYYY.html` to `root@astro.kias.re.kr:/BACKUP3/www/html/KDES_seminar/`
via `scp`. Requires SSH key auth to be set up (see the `KEY` variable in `deploy.sh`).

### 5. Announce to the mailing list

Draft the announcement from the "Meeting announcement" template in
`email_templates.md`, filling in the meeting details and abstracts. Keep the
working draft in `drafts/email-draft-NNNth.md` and commit it. Send it to the
mailing list.
