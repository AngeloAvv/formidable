import '../validation/validation_error.dart';
import '../validation/form_validator.dart';
import 'field.dart';
import 'form_state.dart';
import 'node.dart';
import 'notifier.dart';
import 'status.dart';
import 'submit_result.dart';

/// The live instance generated from a Schema [S].
///
/// A generated Form extends this class, creates its Fields, passes them to
/// [attach] once and implements [buildOutput]. Everything else, including
/// `submit()`, lives here.
abstract class FormidableForm<S>
    with FormidableNotifierMixin
    implements FormidableObservable<FormidableFormState> {
  List<FormidableNode> _nodes = const [];
  List<FormidableFormValidator<FormidableForm<Object?>>> _formValidators =
      const [];
  bool _validatingForm = false;
  FormidableFormState _state = const FormidableFormState(
    status: FormidableStatus.valid,
  );

  /// The children of the Form, in Schema declaration order.
  List<FormidableNode> get nodes => _nodes;

  @override
  FormidableFormState get state => _state;

  /// Registers the children of the Form, in Schema declaration order, and the
  /// [formValidators] declared on the Schema. A generated Form calls it once
  /// from its constructor, with itself as [F].
  void attach<F extends FormidableForm<S>>(
    List<FormidableNode> nodes, {
    List<FormidableFormValidator<F>> formValidators = const [],
  }) {
    assert(_nodes.isEmpty, 'attach must be called once.');
    assert(this is F, 'attach must be given the type of the Form itself.');
    _nodes = List.unmodifiable(nodes);
    _formValidators = formValidators;
    for (final node in _nodes) {
      node.addListener(_onNodeChanged);
    }
    _runFormValidators();
    _state = _computeState();
  }

  /// Builds the Schema instance from the Fields. Called only when every Field
  /// is valid. Implemented by the generated Form.
  S buildOutput();

  /// Decides whether the Form is valid and builds the Schema instance.
  Future<FormidableSubmitResult<S>> submit() async {
    final errors =
        <FormidableField<Object?>, List<FormidableValidationError>>{};
    for (final node in _nodes) {
      node.collectErrors(errors);
    }
    if (errors.isNotEmpty) {
      return FormidableSubmitInvalid<S>(Map.unmodifiable(errors));
    }
    return FormidableSubmitValid<S>(buildOutput());
  }

  @override
  void dispose() {
    for (final node in _nodes) {
      node.removeListener(_onNodeChanged);
      node.dispose();
    }
    super.dispose();
  }

  /// Runs the Form Validators and gives every Field the errors addressed to
  /// it. The Fields notify while this runs, so a listener never has to wait for
  /// a second pass: it sees the final errors.
  void _runFormValidators() {
    if (_formValidators.isEmpty) return;
    _validatingForm = true;
    try {
      final addressed =
          <FormidableField<Object?>, List<FormidableValidationError>>{};
      for (final validator in _formValidators) {
        // Safe at runtime: attach() only accepts validators typed on this Form.
        for (final item in validator.validate(this)) {
          assert(
            _nodes.contains(item.field),
            'A Form Validator addressed an error to a Field that is not in '
            'this Form.',
          );
          (addressed[item.field] ??= []).add(item.error);
        }
      }
      for (final node in _nodes) {
        if (node is FormidableField<Object?>) {
          node.replaceFormErrors(addressed[node] ?? const []);
        }
      }
    } finally {
      _validatingForm = false;
    }
  }

  void _onNodeChanged() {
    if (!_validatingForm) _runFormValidators();
    final next = _computeState();
    if (next == _state) return;
    _state = next;
    notifyListeners();
  }

  FormidableFormState _computeState() => FormidableFormState(
    status: _nodes.every((node) => node.isValid)
        ? FormidableStatus.valid
        : FormidableStatus.invalid,
  );
}
