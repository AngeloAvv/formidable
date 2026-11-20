# Own reactivity primitive, without bloc

Forms and Fields expose immutable state snapshots and notify listeners synchronously, in a way compatible with `ValueListenable`. The builder, listener and selector widgets are designed to feel like flutter_bloc, but they do not depend on bloc.

We considered making each Form a Cubit. We rejected it for two reasons. The core must stay pure Dart with no dependencies (ADR-0001). And a model built only on streams cannot give builders a synchronous initial value. If a bloc adapter is ever needed, it will ship as a separate package.
