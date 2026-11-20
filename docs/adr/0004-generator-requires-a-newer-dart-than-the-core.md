# The generator requires a newer Dart than the core

The core package requires Dart 3.8, while the generator requires Dart 3.11.

The core holds the runtime and the annotations. Schemas depend on it, and Schemas can live in domain packages that don't use Flutter or code generation. A low minimum keeps those packages free to stay on older SDKs.

The generator is a dev dependency that only runs at build time. It is built on the current analyzer, `source_gen` and `build` releases, and these require Dart 3.11. Supporting Dart 3.8 in the generator would mean supporting several older major versions of the analyzer API at once, which would make the generator harder to maintain for little benefit. A developer who runs the generator already uses a recent toolchain, because the Flutter packages require Flutter 3.50.

The cost is that the two packages state different SDK minimums even though they share one version.
