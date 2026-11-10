# rubrique.co

Static website for Rubrique Advisory Co., hosted on GitHub Pages at https://www.rubrique.co.

Plain HTML, CSS, and JavaScript. No build step, no frameworks, no dependencies.

## Structure

```
index.html              Home
services/index.html     Services
team/index.html         Team
about/index.html        About
contact/index.html      Contact form (Formspree)
404.html                Not-found page
assets/css/site.css     All styles (palette variables at the top)
assets/js/site.js       Mobile menu, hero word rotator, form submit
assets/fonts/           Self-hosted Anton, Poppins, Epilogue (OFL)
assets/img/             Images (populate with scripts/fetch-images.sh)
scripts/fetch-images.sh One-time image download from the old Squarespace site
robots.txt, sitemap.xml SEO basics
.nojekyll               Tells GitHub Pages to serve files as-is
```

## Deploy

See **DEPLOY.md** for the full, step-by-step guide (GitHub Pages, Squarespace DNS, Google Workspace email, HTTPS, Formspree).

## Edit

Edit any file on GitHub (pencil icon) and commit; the live site updates in about a minute. The header and footer are repeated in every page, so navigation changes need to be made in all six HTML files.
