import 'form.dart';
import 'node.dart';

/// A rule declared on a Schema that changes some Fields when others change,
/// for example clearing the province when the country changes.
///
/// An Effect is a const class typed on the generated Form [F]. It is declared
/// with `@Effects([...])` on the Schema, and receives the typed Form, so it
/// reads and writes Fields through their handles and can be tested without any
/// UI.
///
/// Effects run synchronously after a change and before validation, in the
/// order they are declared, and once when the Form is created. When an Effect
/// changes a Field, every Effect runs again until nothing changes any more, so
/// an Effect should only write when the value actually has to change.
///
/// Writes made by an Effect go through the Field's Normalizers, are never
/// marked as touched and do not notify anyone until validation is done.
abstract class FormidableEffect<F extends FormidableForm<Object?>> {
  const FormidableEffect();

  /// Applies the rule to [form].
  ///
  /// Read Fields through [FormidableField.value] and
  /// [FormidableField.defined]: their `state` (errors included) is only updated
  /// after every Effect has run.
  void apply(F form, FormidableEffectContext context);
}

/// What an Effect can ask about the change that triggered it.
final class FormidableEffectContext {
  const FormidableEffectContext(this._changed);

  final Set<FormidableNode> _changed;

  /// Whether [node] changed its value or presence since the previous run of
  /// the Effects: the user's or programmatic write on the first run, then what
  /// the Effects themselves changed. It is false for every Field when the Form
  /// is created, so an Effect never clears data that came with the initial
  /// values.
  bool changed(FormidableNode node) => _changed.contains(node);
}

/// Thrown in debug builds when Form Effects keep changing Fields without ever
/// settling, which means they trigger each other in a loop.
final class FormidableEffectLoopError extends StateError {
  FormidableEffectLoopError(
    List<FormidableEffect<FormidableForm<Object?>>> effects,
    int passes,
  ) : super(
        'Form Effects did not settle after $passes passes, so they probably '
        'trigger each other in a loop. Make each Effect write a Field only '
        'when its value has to change. Effects involved: '
        '${effects.map((e) => e.runtimeType).join(', ')}.',
      );
}
