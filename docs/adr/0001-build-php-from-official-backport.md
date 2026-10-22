# Build PHP 7.4 ourselves from the official backport, not a community image

PHP 7.4 is end-of-life, and no Docker Official Image includes the upstream fixes for CVE-2026-109618/109619. We will build PHP ourselves. The inputs are the signed `php-7.4.33.tar.xz` release tarball plus php-src commit `712e60f9ed` (branch `PHP-7.4-CVE-2026-109618-109619`), applied as a patch file pinned by sha256. The build uses docker-library's last official 7.4 Alpine recipe.

## Considered Options

- **Community image** `ghcr.io/mpyw/php-eol-cve-2026-109618-109619` (proposed in api PR #396). Rejected: it puts a third party's build pipeline into our supply chain for the production runtime. We can't reproduce or audit it beyond its provenance metadata, and each future fix would depend on that maintainer.
- **Stay on PHP 7.3.** Rejected: upstream published no 7.3 backport, so both CVEs would stay open.

## Consequences

- We maintain this PHP build ourselves. Any future backport has to be pulled in and rebuilt by us.
- The image keeps reporting PHP `7.4.33`, so we need another way to prove the patch is present (the `max_multipart_body_parts` ini setting exists).
- The backport changes what happens when a request hits `memory_limit`: PHP calls `_exit(1)`, so nginx returns a 502, and neither Laravel's shutdown handlers nor Bugsnag see the error. We accept this upstream behaviour and do not patch around it. Out-of-memory failures are visible only in the container logs (`Allowed memory size`, `child … exited with code 1`) and as nginx 502s. CloudWatch alarms on these are deferred, not built at rollout.
