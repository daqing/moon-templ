///|
/// `usleep` is the one part of the watch loop that belongs to the operating
/// system: the language has no timer of its own.
extern "C" fn usleep(microseconds : UInt32) -> Int32 = "usleep"

///|
fn pause(milliseconds : Int32) -> Unit {
  usleep((milliseconds * 1000).reinterpret_as_uint()) |> ignore
}

///|
fn watch_supported() -> Bool {
  true
}
