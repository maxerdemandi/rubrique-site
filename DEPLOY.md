# Deploying rubrique.co on GitHub Pages

This guide moves www.rubrique.co from Squarespace to GitHub Pages without breaking your Google Workspace email (hello@, max@, lahne@, groznik@). Follow the steps in order. The Squarespace site stays live until Step 7, and you cancel Squarespace only at the very end, so you can roll back at any point.

Time needed: about 60 to 90 minutes of hands-on work, plus up to 24 hours of waiting for DNS and the HTTPS certificate.

Throughout, replace `USERNAME` with your GitHub username.

---

## What I found on your current setup (checked November 10, 2026)

| Item | Current value | What happens |
|---|---|---|
| DNS host | Squarespace (`nsd1` to `nsd4.squarespacedns.com`) | You edit DNS in Squarespace. Nothing moves. |
| Website (apex) | 4 A records to Squarespace (198.49.23.144, 198.49.23.145, 198.185.159.144, 198.185.159.145) | **Delete** in Step 7 |
| Website (www) | CNAME `www` to `ext-sq.squarespace.com` | **Delete** in Step 7 |
| Email | MX `smtp.google.com` (priority 1) | **Keep** |
| SPF | TXT `v=spf1 include:_spf.google.com ~all` | **Keep** |
| DKIM | TXT at `google._domainkey` | **Keep** |
| DMARC | TXT at `_dmarc` | **Keep** |
| Google verification | TXT `google-site-verification=...` | **Keep** |

Rule of thumb for Step 7: delete only the five website records listed above. Leave every Google record alone.

---

## Before you start

1. **Confirm who registers the domain.** In Squarespace, open the Domains dashboard and click `rubrique.co`.
   - If it shows a renewal date and "Squarespace domain," you are set. Canceling the *website* subscription later does not cancel the domain, and DNS stays editable in the Domains panel.
   - If it says the domain is registered elsewhere and connected with "Nameserver Connect," stop and tell me. In that case DNS hosting would disappear when you leave Squarespace, which would take email down with it, and we need to move DNS first.
2. Note whether **Google Workspace** is billed through Squarespace (Squarespace Settings, Billing, Subscriptions). If it is, you will keep that subscription active in Step 9.
3. Create a free account at https://github.com if you don't have one. Optional: create a free GitHub *organization* named `rubrique` (or similar) and put the repository there, so the site belongs to the firm rather than to your personal account. If you do, use the organization name everywhere this guide says `USERNAME`.

---

## Step 1. Download the images (do this first, while Squarespace is live)

The logo, headshots, and photos currently live on Squarespace's image servers, which may stop serving them after you cancel. The included script copies them into the site.

Open **Terminal** (Applications, Utilities) and run:

```bash
cd ~/Desktop/LLC/rubrique-site
bash scripts/fetch-images.sh
```

You should see 16 downloads, then a listing of `assets/img/` with files such as `logo.png`, `favicon.png`, `team-max-erdemandi.jpg`, and `home-hero.jpg`. The script uses macOS's built-in `sips` tool to resize the large photos and create `favicon.png` and `og-image.jpg`.

**Optional local preview.** In the same Terminal window:

```bash
python3 -m http.server 8000
```

Then open http://localhost:8000 in your browser. Press `Ctrl+C` in Terminal to stop. (If macOS asks to install developer tools for `python3`, you can skip the preview and check the site on GitHub in Step 4 instead.)

---

## Step 2. Connect the contact form (Formspree)

GitHub Pages serves static files only, so the form needs an outside service to email you submissions. The site is wired for Formspree.

1. Sign up at https://formspree.io using `hello@rubrique.co` (submissions are emailed to the account address).
2. Click **New form**, name it "rubrique.co contact," and create it.
3. Copy the form endpoint. It looks like `https://formspree.io/f/abcdwxyz`. The part after `/f/` is your form ID.
4. Open `contact/index.html` in any text editor (TextEdit works; use Format, Make Plain Text) and replace `YOUR_FORM_ID` with your ID. There is exactly one occurrence:
   ```html
   <form ... action="https://formspree.io/f/YOUR_FORM_ID" method="POST">
   ```
5. Save.
6. Recommended: in the Formspree form settings, restrict submissions to your domains (`rubrique.co`, `www.rubrique.co`, and `USERNAME.github.io` while testing) to cut spam.

Plan limits: as of mid-2026, Formspree's free tier allows 50 submissions per month with a 30-day archive; paid plans start around $10 to $15 per month. Check https://formspree.io/plans for current terms. For a boutique practice, 50 a month is usually enough.

Until you add the ID, the form tells visitors to email hello@rubrique.co instead of failing silently.

---

## Step 3. Create the repository and upload the site

### Option A: in the browser (no software needed)

1. Go to https://github.com/new.
2. Repository name: `rubrique-site`. Visibility: **Public** (GitHub Pages on a free account requires a public repository). Leave "Add a README" unchecked. Click **Create repository**.
3. On the empty repository page, click the link **uploading an existing file**.
4. In Finder, open `~/Desktop/LLC/rubrique-site`. Press `Cmd+Shift+.` to show hidden files so you can see `.nojekyll`.
5. Select **everything inside** the folder (`Cmd+A`) and drag it onto the GitHub upload page. Upload the *contents*, not the `rubrique-site` folder itself. `index.html` must sit at the top level of the repository.
6. Scroll down, type a message such as "Initial site," and click **Commit changes**.

### Option B: Terminal and git

```bash
cd ~/Desktop/LLC/rubrique-site
git init -b main
git add .
git commit -m "Initial site"
git remote add origin https://github.com/USERNAME/rubrique-site.git
git push -u origin main
```

(Create the empty repository at https://github.com/new first. If git asks for a password, use a personal access token or install GitHub Desktop, which handles sign-in for you.)

---

## Step 4. Turn on GitHub Pages and check the preview

1. In the repository, open **Settings**, then **Pages** (left sidebar).
2. Under **Build and deployment**: Source = **Deploy from a branch**. Branch = **main**, folder = **/ (root)**. Click **Save**.
3. Wait one to two minutes. The page will show "Your site is live at `https://USERNAME.github.io/rubrique-site/`."
4. Open that address and check every page: Home, Services, Team, About, Contact. Confirm the logo and photos appear and the mobile menu works (narrow the browser window).
5. Submit a test message through the contact form. Formspree may email you once to confirm the form; click the link, then submit again and confirm the message reaches hello@rubrique.co.

Do not continue until the preview looks right. Fixing things here costs nothing; Squarespace is still serving the real domain.

---

## Step 5. Verify the domain with GitHub (recommended)

Verification stops anyone else from claiming rubrique.co on GitHub if your site is ever unpublished.

1. Click your profile picture (top right), then **Settings**. In the sidebar under "Code, planning, and automation," click **Pages**. (For an organization: the organization's Settings, then Pages.)
2. Click **Add a domain**, enter `rubrique.co`, click **Add domain**.
3. GitHub shows a TXT record, with a host like `_github-pages-challenge-USERNAME` and a random value.
4. In Squarespace: Domains, `rubrique.co`, **DNS**, **DNS Settings**. Under **Custom Records**, add:
   - Host: `_github-pages-challenge-USERNAME`
   - Type: `TXT`
   - Data: the value GitHub gave you
5. Save, wait a few minutes, then click **Verify** on GitHub. If it fails, wait 15 to 30 minutes and try again.

---

## Step 6. Add the custom domain to the repository

1. Repository **Settings**, **Pages**, **Custom domain**: enter `www.rubrique.co` and click **Save**.
2. GitHub adds a file named `CNAME` to the repository. That is expected. Leave it there.
3. The DNS check will show an error until you finish Step 7. That is also expected.

Why `www.rubrique.co` and not the bare domain: your current site is served at www, so search engines and existing links already point there. GitHub will redirect `rubrique.co` to `www.rubrique.co` automatically once both records exist.

Note: from this moment, the `github.io` preview address redirects to www.rubrique.co, which still shows Squarespace until Step 7. Do Step 7 right away.

---

## Step 7. Point DNS at GitHub (the cutover)

In Squarespace: Domains, `rubrique.co`, **DNS**, **DNS Settings**.

### 7a. Delete the Squarespace website records

In the **Squarespace Defaults** (sometimes labeled "Website Defaults") section, hover over each record and click the trash icon:

- A `@` 198.49.23.144
- A `@` 198.49.23.145
- A `@` 198.185.159.144
- A `@` 198.185.159.145
- CNAME `www` ext-sq.squarespace.com

If any of these appear under Custom Records instead, delete them there. **Do not delete** anything mentioning Google, `smtp.google.com`, `_spf.google.com`, `google._domainkey`, `_dmarc`, or `google-site-verification`.

### 7b. Add the GitHub Pages records

Under **Custom Records**, click **Add record** for each row:

| Host | Type | Data |
|---|---|---|
| `@` | A | `185.199.108.153` |
| `@` | A | `185.199.109.153` |
| `@` | A | `185.199.110.153` |
| `@` | A | `185.199.111.153` |
| `@` | AAAA | `2606:50c0:8000::153` |
| `@` | AAAA | `2606:50c0:8001::153` |
| `@` | AAAA | `2606:50c0:8002::153` |
| `@` | AAAA | `2606:50c0:8003::153` |
| `www` | CNAME | `USERNAME.github.io` |

The `www` CNAME points to your GitHub username (or organization) domain only. Do not add `/rubrique-site`.

These IP addresses come from GitHub's documentation (see Sources at the end). Check that page if you are doing this long after November 2026.

### 7c. Final DNS should look like this

- 4 A + 4 AAAA records on `@` (GitHub)
- 1 CNAME on `www` (GitHub)
- MX, SPF, DKIM, DMARC, google-site-verification (Google, unchanged)
- `_github-pages-challenge-USERNAME` TXT (GitHub verification)

---

## Step 8. Wait for DNS, then turn on HTTPS

1. Changes usually take effect within an hour; GitHub says up to 24 hours.
2. Check progress from Terminal:
   ```bash
   dig www.rubrique.co +short     # should show USERNAME.github.io and 185.199.x.153 addresses
   dig rubrique.co +short         # should show the four 185.199.x.153 addresses
   dig rubrique.co MX +short      # should still show: 1 smtp.google.com.
   ```
3. In repository **Settings**, **Pages**, the DNS check turns green. GitHub then requests a free TLS certificate. When the **Enforce HTTPS** checkbox becomes clickable (can take up to 24 hours), tick it.
4. Test:
   - https://www.rubrique.co loads the new site with a padlock.
   - https://rubrique.co redirects to https://www.rubrique.co.
   - Old Squarespace addresses still work: `/services`, `/team`, `/about`, `/contact` (GitHub redirects each to the version with a trailing slash).
   - Send an email to hello@rubrique.co from a personal account and confirm it arrives.
   - Submit the contact form on the live domain.

---

## Step 9. Cancel the Squarespace website plan (last)

Wait until the new site has run cleanly on HTTPS for a day or two. Then, in Squarespace: **Settings**, **Billing**, **Subscriptions**:

- **Cancel:** the Website subscription.
- **Keep active:** the `rubrique.co` Domain subscription (leave auto-renew on).
- **Keep active:** Google Workspace, if it is billed through Squarespace.

After cancellation you still manage DNS in the Squarespace Domains panel. If you later want to stop paying Squarespace for the domain, you can transfer it to another registrar (for example Cloudflare Registrar), but that is a separate project and not required.

**Rollback (any time before Step 9):** delete the GitHub records from Step 7b and re-add the Squarespace Defaults. Squarespace's help pages note you can add its default records back if needed. The Squarespace site comes back as soon as DNS updates.

---

## Step 10. After launch

- **Google Search Console:** your existing `google-site-verification` record stays valid. In Search Console, submit `https://www.rubrique.co/sitemap.xml`.
- **LinkedIn:** the company page already links to www.rubrique.co; nothing to change.
- **Analytics:** Squarespace analytics stop when you cancel. If you want traffic data, add a privacy-friendly tool such as GoatCounter (free for small sites) or Plausible (paid) by pasting its one-line script before `</body>` in each page.

---

## Editing the site later

- **Small text changes:** open the file on GitHub, click the pencil icon, edit, and click **Commit changes**. The live site updates in about a minute.
- **Where things live:**
  - `index.html` (Home), `services/index.html`, `team/index.html`, `about/index.html`, `contact/index.html`
  - `assets/css/site.css` (colors, fonts, layout; the palette is at the top)
  - `assets/js/site.js` (mobile menu, headline word rotator, form handling)
  - `assets/img/` (images; keep the same file names to swap a photo)
- **The header and footer are repeated in each page.** If you change the navigation or footer, change it in all five page files plus `404.html`.
- **To add a page:** copy an existing folder (for example `about/`), rename it, edit its `index.html`, add it to the nav in every page, and add its URL to `sitemap.xml`.

---

## Troubleshooting

| Symptom | Likely cause and fix |
|---|---|
| GitHub preview shows 404 | Pages source is not `main` / `(root)`, or `index.html` is inside a subfolder. Re-upload the folder's contents, not the folder. |
| Pages load without styling | Same cause: files nested one level too deep. |
| Logo or photos missing | Step 1 was skipped, or `assets/img/` was not uploaded. |
| "DNS check unsuccessful" in Pages settings | Wait; then confirm with `dig`. Make sure all four Squarespace A records and the old `www` CNAME are gone. |
| Enforce HTTPS stays greyed out | Wait up to 24 hours. If still stuck, clear the Custom domain field, save, re-enter `www.rubrique.co`, and save again to restart certificate issuance. |
| Email stops arriving | The MX record was removed. Re-add: Host `@`, Type MX, Priority 1, Data `smtp.google.com`. |
| Form says "not connected yet" | `YOUR_FORM_ID` is still in `contact/index.html`. |
| Form returns an error | Confirm the Formspree verification email, and check the allowed-domains setting in Formspree. |

---

## Things to know

- **GitHub's terms on commercial sites.** GitHub says Pages is not intended as free hosting for running an online business or e-commerce site, meaning sites mainly used for commercial transactions or SaaS. A static marketing site with no payments or logins is a common use and, in my reading, falls outside that restriction, but GitHub does not define the line precisely. If you prefer a host whose free tier allows business use explicitly, this exact folder deploys unchanged to Cloudflare Pages or Netlify.
- **The repository is public.** Anyone can see the site files. That includes the team email addresses, which are already public on the current site. Never commit passwords or client data.
- **Fonts are self-hosted** in `assets/fonts/` (Anton, Poppins, Epilogue; SIL Open Font License, license files included), so the site makes no calls to Google Fonts.
- **One contact form instead of three.** The Squarespace site had forms on Home, Services, and Contact. The new site has one form on the Contact page that merges the fields (including services of interest and budget range). Buttons across the site link to it, and `?interest=diagnostic` or `?interest=flagship` pre-ticks the matching service. The country dropdown was dropped; phone stays optional.

---

## Copy edits I made while rebuilding

I kept the live site's wording and structure, with these corrections:

**Factual alignment (please confirm)**
- Earnings-test stat: "can lose federal funds and loan eligibility" became "can lose federal student loan eligibility," to match the wording in Strategy Brief v3.1 (a program that fails in two of any three consecutive years loses eligibility for federal student loans). If you have a source for the broader "federal funds" claim, revert it.
- International enrollment stat: "the largest drop in over a decade outside of the COVID-19" became "the largest non-pandemic drop in over a decade."

**Content filled in**
- Phase One, Two, and Three accordions on the Services page were empty on the live site. I filled them from Website Content v2 (deliverables and "best for" lines, without prices).
- Added a Data Readiness Diagnostic button inside Phase Zero, two buttons in the home hero, and a short intro line on the Team page.

**Grammar and typos**
- "questions you organization wants" → "your organization"; "donor and alumni relations';" → "relations;"
- Services: "the ones ... donors most wants proof of" → "want"; "translates ..., evaluate ..., and connect" → "evaluates ... connects"; added the missing period before "But every soft claim"; "6 to 8weeks" → "6 to 8 weeks"
- Team: "help institutions to assess the impact of centered programs" → "assess the impact of student-centered programs"; "Nearly a decade in federally funded research, Max administered" → "Over nearly a decade..."; "the institutional stories clients tell stays clear ... true to the evidence behind it" → "stay clear ... behind them"
- About: "nearly a decade experience" → "nearly a decade of experience"; "their provost and your board" → "their provost and board"; tightened "supported by an expert team, spanning experts in" → "supported by a team with expertise in"
- Removed em dashes throughout, per your style preference.

---

## Sources

- GitHub Docs. *Managing a custom domain for your GitHub Pages site.* https://docs.github.com/en/pages/configuring-a-custom-domain-for-your-github-pages-site/managing-a-custom-domain-for-your-github-pages-site
- GitHub Docs. *GitHub Pages limits.* https://docs.github.com/en/pages/getting-started-with-github-pages/github-pages-limits
- Squarespace Help. *Adding DNS records to your domain.* https://support.squarespace.com/hc/articles/360002101888
- Formspree. *Plans.* https://formspree.io/plans
