# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](http://keepachangelog.com/en/1.0.0/)
and this project adheres to [Semantic Versioning](http://semver.org/spec/v2.0.0.html).

## [Unreleased]

## [2.1.0]

### Added

- Added `Pragma::Policy::Pundit` for policies that just delegate to Pundit
- Implemented `#context` as an alias of `#user`

### Changed

- `Pragma::Policy::Base::Scope` has been moved to `Pragma::Policy::Scope` (alias provided for BC)
- `Pragma::Policy::UnauthorizedError` no longer inherits from `Pundit::UnauthorizedError`

### Removed

- Dropped Pundit dependency

## [2.0.0]

First Pragma 2 release.

[Unreleased]: https://github.com/pragmarb/pragma-policy/compare/v2.1.0...HEAD
[2.1.0]: https://github.com/pragmarb/pragma-policy/compare/v2.0.0...v2.1.0
[2.0.0]: https://github.com/pragmarb/pragma-policy/compare/v0.1.0...v2.0.0
