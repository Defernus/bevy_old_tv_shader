# bevy_old_tv_shader

An "old TV" effect based on the Bevy [post-processing example](https://github.com/bevyengine/bevy/blob/main/examples/shader/custom_post_processing.rs). 
<p align="center">
  <img src="https://github.com/user-attachments/assets/0718c9f0-177d-473b-bfe8-13c9482bc197" alt="Movie of the old TV shader effect in action on 'cube' example."/>
</p>

# Usage
To use this effect, add the crate to your project.

## Add the crate

``` sh
cargo add --git https://github.com/Defernus/bevy_old_tv_shader.git
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

# Features

## "ui"
Applies the effect to the UI and text as well.

# Examples

## cube, 3d camera

The "cube" example shows a rotating cube with the effect (shown above).

``` sh
cargo run --example cube
```

## shapes, 2d camera

The "shapes" example shows 2d shapes.

``` sh
cargo run --example shapes
```
![shapes](https://github.com/user-attachments/assets/26f19e79-8bed-4260-ad3e-863ebc481b5d)

## text

The "text" example shows UI text with or without the effect.

### No effect on UI
``` sh
cargo run --example text
```

### Effect on UI
``` sh
cargo run  --features ui --example text
```
![text](https://github.com/user-attachments/assets/f51f75f8-b39a-4348-92d8-bdc03da7e6b3)

The "text" example also accepts an argument of "3d-camera". This was mainly used
to spotcheck that the effect worked with a 3d camera.

### Effect on UI with 3d camera
``` sh
cargo run  --features ui --example text 3d-camera
```
# Compatibility

| bevy_old_tv_shader | bevy |
|--------------------|------|
| 0.2.0              | 0.15 |
| 0.1.0              | 0.8  |

# License

This crate is licensed under the MIT License.
