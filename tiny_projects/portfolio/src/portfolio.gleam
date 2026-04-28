import blogatto
import blogatto/error
import gleam/io
import portfolio/site_config

pub fn main() {
  let cfg = site_config.config()

  case blogatto.build(cfg) {
    Ok(Nil) -> io.println("Site built successfully in ./dist")
    Error(err) -> io.println("Build failed: " <> error.describe_error(err))
  }
}
