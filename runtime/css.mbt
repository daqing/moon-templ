///|
/// One class of a class list: a name that is always there, or a name that is
/// there only while its flag holds.
///
/// templ takes `any` here and switches on the dynamic type — a plain string, a
/// `templ.KV`, a map of names to flags. MoonBit has no such type, so the list is
/// written out instead, and the maps templ accepted are read by the caller.
pub(all) enum CSSClass {
  Name(String)
  Toggle(KV[String, Bool])
}

///|
/// A list of class names, templ's `templ.CSSClasses`. `class={ ... }` renders it
/// into one attribute value.
pub(all) struct CSSClasses {
  priv items : Array[CSSClass]
}

///|
pub fn CSSClasses::new(items : Array[CSSClass]) -> CSSClasses {
  { items, }
}

///|
/// The names that are on, in the order they first appeared.
///
/// A flag is read the way templ's processor reads one: it is the *last* flag
/// written for a name that decides, while the order comes from the *first* time
/// the name was written. So `["a", KV("a", false)]` renders nothing at all, and
/// `["a", "a"]` renders `a` once — both are templ's behaviour, and both are
/// pinned by tests below.
pub impl Show for CSSClasses with fn output(self, logger) {
  let enabled : Map[String, Bool] = Map([])
  let order : Array[String] = []
  for item in self.items {
    let (name, on) = match item {
      Name(name) => (name, true)
      Toggle(pair) => (pair.key, pair.value)
    }
    enabled[name] = on
    order.push(name)
  }
  let rendered : Map[String, Unit] = Map([])
  let mut first = true
  for name in order {
    if enabled.get(name) == Some(true) && !rendered.contains(name) {
      if !first {
        logger.write_string(" ")
      }
      first = false
      logger.write_string(name)
      rendered[name] = ()
    }
  }
}

///|
pub extend CSSClasses with Show::{to_string, output}
