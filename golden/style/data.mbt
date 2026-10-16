///|
/// What templ's `getFunctionResult` answers: a style string the template reaches
/// by calling rather than by being handed one. templ's version returns an error
/// beside it, which only the runtime's own signature distinguishes — a style
/// value here is a string, and a call that fails is not one this port has.
pub fn get_function_result() -> String {
  "background-color: red"
}
