Change the nushell version in the cargo.toml to the one that you're using
```
nu --version
```

Toml to
```
nu-plugin = "0.109.1"
nu-protocol = { version = "0.109.1", features = ["plugin"] }
```

Build the thing
```
cargo build --release
```

Copy the plugin from the target directory to your plugins directory
```
cp ./target/release/nu_plugin_geospatial ~/.config/nushell/plugins/nu_plugin_geospatial
```

Register the plugin (run this once in your nushell terminal)
```
plugin add ~/.config/nushell/plugins/nu_plugin_geospatial
```

Then add these lines to the bottom of your env.nu file
```
try {
    plugin add ~/.config/nushell/plugins/nu_plugin_geospatial
    plugin use ~/.config/nushell/plugins/nu_plugin_geospatial
}
```

Then restart your nushell

Example of how to use it:
```
"POINT(1 1)" | from wkt | into wkb
```