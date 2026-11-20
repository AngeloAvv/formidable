# Unset is not null

A Field has a presence state that is separate from its value. It is either Unset, or it holds a value of type `T`, and that value can be null when `T` is nullable. "Required" means "not Unset". It does not mean "not null".

The Schema type decides which Fields are required. A non-nullable Field without a default is required, and a nullable Field is optional. Putting `@Required()` on a nullable Field forces the user to choose, and choosing null counts as a choice.

If required meant "not null", there would be no way to say "the user must choose" when null is one of the choices. An example is a group of three radio buttons where A means null, B means true and C means false. We also considered forbidding null as a choice and telling users to model it as an enum. We rejected that because it would force a limitation of the library onto the user's domain model.

The cost of this decision is that Codecs and widgets must decide what counts as Unset. For example, a blank text input is Unset, while selecting the radio option that stands for null sets the value to null.
