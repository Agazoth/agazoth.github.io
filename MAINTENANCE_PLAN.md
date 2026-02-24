# Website Assessment and Maintenance Plan (2026-02-22)

## Immediate Priority (P0)

- [x] Added `app-ads.txt` to site root.
- [x] Added `ads.txt` to site root (canonical ads endpoint).
- [x] Verify ad entry values in both files.
- [x] Deploy site so the file is publicly reachable.
- [x] Verify over HTTPS after deploy.

## Current Assessment

### Platform / Build
- Site is a Jekyll + Minima blog with Ruby/Bundler build scripts in `script/`.
- Dependency stack is very old (`github-pages` lockfile resolves to Jekyll 3.7.4 / Minima 2.5.0).
- Local build is now validated with Ruby 3.3 + Bundler (`bundle exec jekyll build`).

### Repo Hygiene
- Added a minimal CI workflow to verify root ad files are present.
- Added a CI workflow to run Jekyll build on push/PR.
- Project README is now a site-specific operations runbook.
- Site config now has production `url` set to `https://agazoth.github.io`.

### Content / Operations
- Post content exists through 2025 (site is not abandoned), but operational setup appears stale.
- Analytics/Disqus include templates are present; integrations should be validated against current IDs and privacy requirements.

## Maintenance Plan

### Phase 1: Stabilize (Today)
1. Set and validate production site URL in `_config.yml`.
2. Ensure `app-ads.txt` and `ads.txt` contain the real ad account lines.
3. Deploy and verify these URLs:
   - `/`
   - `/app-ads.txt`
   - `/ads.txt`
   - `/feed.xml`
4. Confirm analytics/comments behavior in production.

### Phase 2: Recover Build Reliability (This Week)
1. [x] Install Ruby + Bundler on your workstation.
2. [x] Run `bundle install` and `bundle exec jekyll build`.
3. [x] Document local setup and deploy steps in README.
4. [x] Add a minimal GitHub Actions workflow to build on push/PR.

### Phase 3: Modernize Safely (1-2 Weeks)
1. [x] Create upgrade branch for `github-pages` and related gems.
2. [x] Update dependencies incrementally; run build after each bump.
   - First bump completed: `github-pages` 197 -> 231
   - Second bump completed: added `faraday-retry` to address Faraday v2 retry warning
   - Security bump completed: `faraday` 2.8.1 -> 2.14.1 and `nokogiri` 1.15.7 -> 1.19.1
   - Security mitigation completed: `minima.gemspec` Bundler dev dependency updated to `~> 2.1.0`
   - Remaining dependency check: `bundle outdated --strict` reports bundle up to date
   - Validation completed: `bundle exec jekyll build` successful after upgrade
3. [x] Check rendering diffs for posts/layout includes.
   - Verified `_site/index.html`, `_site/feed.xml`, `_site/ads.txt`, `_site/app-ads.txt` are generated.
   - Verified header nav shows only About/Links and no Maintenance Plan link.
   - Verified all 21 source posts render under `_site/blogpost/...`.
4. [x] Deploy after content + visual verification.

#### Production Deploy Verification Checklist
- [x] Push branch and merge/deploy to GitHub Pages source branch.
- [x] Wait for Pages build to complete successfully.
- [x] Verify homepage loads: `https://agazoth.github.io/`
- [x] Verify feed loads: `https://agazoth.github.io/feed.xml`
- [x] Verify ad files load:
   - `https://agazoth.github.io/ads.txt`
   - `https://agazoth.github.io/app-ads.txt`
- [x] Verify internal docs are not published:
   - `https://agazoth.github.io/README.html` returns not found
   - `https://agazoth.github.io/MAINTENANCE_PLAN.html` returns not found
- [x] Verify header navigation includes only About and Links.
- [x] Spot-check latest 3 posts under `/blogpost/...` paths.

### Phase 4: Ongoing Maintenance (Monthly)
1. Dependency refresh check.
2. Broken-link scan and feed/homepage check.
3. Validate analytics/ad file/comment integrations.
4. Publish at least one maintenance note/changelog entry.

Default monthly command:

`$env:Path = 'C:\Ruby33-x64\bin;' + $env:Path; .\script\monthly-check.ps1`

#### Monthly Runbook Checklist (copy each month)
- [ ] Run `bundle outdated --strict` and note changes.
- [ ] Run `bundle exec jekyll build` locally.
- [ ] Verify production endpoints:
   - [ ] `https://agazoth.github.io/`
   - [ ] `https://agazoth.github.io/feed.xml`
   - [ ] `https://agazoth.github.io/ads.txt`
   - [ ] `https://agazoth.github.io/app-ads.txt`
- [ ] Verify internal docs are still excluded from publish.
- [ ] Check latest post page renders correctly.
- [ ] Review CI workflow results for the month.
- [ ] Add a short maintenance note to repo history.

## Acceptance Criteria

- Root ad file serves correctly in production.
- Local build runs successfully from clean environment.
- CI catches build regressions automatically.
- README documents how to run and maintain the site.
