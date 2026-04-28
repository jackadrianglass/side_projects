import blogatto/dev
import blogatto/error
import gleam/io
import portfolio/website

pub fn main() {
  let cfg = website.config()

  case
    cfg
    |> dev.new()
    |> dev.start()
  {
    Ok(Nil) -> io.println("Dev server stopped.")
    Error(err) -> io.println("Dev server error: " <> error.describe_error(err))
  }
}
