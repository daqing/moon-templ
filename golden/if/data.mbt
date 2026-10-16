///|
/// The data templ's `test-if` golden renders, as MoonBit: Go's `data` is a type
/// name, and MoonBit type names start with a capital, so the port spells it
/// `Data`.
///
/// The golden's own `IsTrue` returns a constant `true`, which covers one branch
/// of the template; this one answers with what it was given, so the test can
/// cover both.
pub struct Data {
  value : Bool
}

///|
/// A value of the data `render` reads.
pub fn Data::new(value : Bool) -> Data {
  { value, }
}

///|
pub fn Data::is_true(self : Data) -> Bool {
  self.value
}
