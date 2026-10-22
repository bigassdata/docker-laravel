# SenseMe PHP runtime images

The container images that the SenseMe Laravel services (api, auth-server) run on, and how those images get security fixes after PHP itself has gone end-of-life.

## Language

**Backport**:
An upstream php-src security fix that the PHP project has published for an EOL branch but not as a release.
_Avoid_: hotfix, patch release

**Community build**:
A PHP image built and published by a third party rather than by us or by Docker Official Images.
_Avoid_: unofficial image

**Base image**:
The `laravel-php` image built from this repo: our patched PHP plus the extensions, ini and tools every App image needs.
_Avoid_: runtime image, docker-laravel image, PHP build

**App image**:
The deployable image for one service (e.g. `senseme-app`), containing the application code on top of the Base image.
_Avoid_: production image, senseme image

**Container role**:
The job one container of the App image performs, selected by `CONTAINER_ROLE`: `app`, `worker`, `scheduler`, `notifications_worker`, `device_status_worker`.
_Avoid_: service, process type
