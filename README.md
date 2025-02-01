# bevy_old_tv_shader

An "old TV" effect based on the Bevy [post-processing example](https://github.com/bevyengine/bevy/blob/main/examples/shader/post_processing.rs). 
<p align="center">
  <img src="https://github.com/user-attachments/assets/0718c9f0-177d-473b-bfe8-13c9482bc197"/>
</p>

# Usage
To use this effect, add the crate to your project.

## Add the crate

``` sh
cargo add --git https://github.com/shanecelis/bevy_old_tv_shader --branch bevy-0.15
```

## Add the plugin

```rust no_run
# use bevy::prelude::*;
# use bevy_old_tv_shader::prelude::*;
fn main() {
    App::new()
        .add_plugins((DefaultPlugins, OldTvPlugin))
        .update();
}
```

## Add the settings to the camera

This effect will only appear on cameras with an `OldTvSettings` component.

```rust no_run
# use bevy::prelude::*;
# use bevy_old_tv_shader::prelude::*;
fn setup_camera(mut commands: Commands) {
    // camera
    commands.spawn((
        Camera3d::default(),
        OldTvSettings {
            screen_shape_factor: 0.2,
            rows: 64.0,
            brightness: 3.0,
            edges_transition_size: 0.025,
            channels_mask_min: 0.1,
        },
    ));
}
```

# Example

The "cube" example shows a rotating cube with the effect.

``` sh
cargo run --example cube
```

# Compatibility

| bevy_minibuffer | bevy |
|-----------------|------|
| 0.2.0           | 0.15 |
| 0.1.0           | 0.8  |

# License

This crate is licensed under the MIT License.
