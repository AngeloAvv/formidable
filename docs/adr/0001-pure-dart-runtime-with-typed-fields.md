# Pure Dart runtime with typed Fields

Formidable's runtime is written in pure Dart and does not depend on Flutter. You reach every Field through a typed handle generated from the Schema. There are no string paths, no `dynamic` values and no runtime casts.

We rejected a model where generic controls are looked up by name. In that model, mistakes the compiler could catch only show up at runtime, and generated code has to rely on casts. A pure Dart runtime also lets Schemas live in domain packages that do not depend on Flutter, and lets you test form logic without flutter_test.
