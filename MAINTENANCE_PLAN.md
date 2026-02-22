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
- Local build was not possible on this machine because `bundle` is not installed.

### Repo Hygiene
- Added a minimal CI workflow to verify root ad files are present.
- Project README is currently the upstream Minima theme README, not site-specific operational docs.
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
1. Install Ruby + Bundler on your workstation.
2. Run `bundle install` and `bundle exec jekyll build`.
3. Document local setup and deploy steps in README.
4. Add a minimal GitHub Actions workflow to build on push/PR.

### Phase 3: Modernize Safely (1-2 Weeks)
1. Create upgrade branch for `github-pages` and related gems.
2. Update dependencies incrementally; run build after each bump.
3. Check rendering diffs for posts/layout includes.
4. Deploy after content + visual verification.

### Phase 4: Ongoing Maintenance (Monthly)
1. Dependency refresh check.
2. Broken-link scan and feed/homepage check.
3. Validate analytics/ad file/comment integrations.
4. Publish at least one maintenance note/changelog entry.

## Acceptance Criteria

- Root ad file serves correctly in production.
- Local build runs successfully from clean environment.
- CI catches build regressions automatically.
- README documents how to run and maintain the site.
