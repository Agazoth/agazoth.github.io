# Instant Automation (agazoth.github.io)

Personal Jekyll blog source for https://agazoth.github.io.

## Current status

- Platform: Jekyll (GitHub Pages gem stack) with Minima theme customizations.
- Production URL configured in [_config.yml](_config.yml).
- Root ad files present:
  - [ads.txt](ads.txt)
  - [app-ads.txt](app-ads.txt)
- Root ad file guard workflow:
  - [.github/workflows/ads-files-check.yml](.github/workflows/ads-files-check.yml)

## Repository layout

- Posts: [_posts/](_posts/)
- Layouts: [_layouts/](_layouts/)
- Includes: [_includes/](_includes/)
- Styles: [_sass/](_sass/) and [assets/main.scss](assets/main.scss)
- Jekyll config: [_config.yml](_config.yml)

## Local development

Prerequisites:

- Ruby 3.3 (recommended for current secure dependency lockfile)
- Bundler

Windows install example:

```powershell
winget install --id RubyInstallerTeam.RubyWithDevKit.3.3 --exact --accept-package-agreements --accept-source-agreements
```

If Ruby is installed but not available in the current terminal, prepend PATH for this session:

```powershell
$env:Path = 'C:\Ruby33-x64\bin;' + $env:Path
```

Install dependencies:

```bash
bundle install
```

Run local server:

```bash
bundle exec jekyll serve
```

Build site:

```bash
bundle exec jekyll build
```

Helper scripts:

- [script/bootstrap](script/bootstrap)
- [script/server](script/server)
- [script/build](script/build)
- [script/monthly-check.ps1](script/monthly-check.ps1)

## Publishing

GitHub Pages serves this repository. For content or config updates:

1. Commit to the branch configured for Pages.
2. Push changes.
3. Verify key endpoints:
   - https://agazoth.github.io/
   - https://agazoth.github.io/ads.txt
   - https://agazoth.github.io/app-ads.txt
   - https://agazoth.github.io/feed.xml

## Maintenance checklist

- Keep [ads.txt](ads.txt) and [app-ads.txt](app-ads.txt) aligned.
- Review [_config.yml](_config.yml) when changing domains or metadata.
- Periodically refresh dependencies in [Gemfile](Gemfile) and [Gemfile.lock](Gemfile.lock).
- Keep [MAINTENANCE_PLAN.md](MAINTENANCE_PLAN.md) up to date.

## Troubleshooting

If `bundle` is not recognized:

1. Install Ruby.
2. Reopen terminal.
3. Run `gem install bundler`.
4. Run `bundle install`.

If you installed multiple Ruby versions, ensure Ruby 3.3 is first in PATH before running Jekyll commands.
