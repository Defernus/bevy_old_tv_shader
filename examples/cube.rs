use bevy::prelude::*;
use old_tv_shader::{OldTvPlugin, OldTvSettings};

/// Set up a simple 3D scene
fn setup(
    mut commands: Commands,
    mut meshes: ResMut<Assets<Mesh>>,
    mut materials: ResMut<Assets<StandardMaterial>>,
) {
    // camera
    commands.spawn((
        Camera3d::default(),
        Transform::from_translation(Vec3::new(0.0, 0.0, 5.0)).looking_at(Vec3::default(), Vec3::Y),
        Camera {
            clear_color: Color::WHITE.into(),
            ..default()
        },
        // Add the setting to the camera.
        // This component is also used to determine on which camera to run the post processing effect.
        OldTvSettings {
            screen_shape_factor: 0.2,
            rows: 64.0,
            brightness: 3.0,
            edges_transition_size: 0.025,
            channels_mask_min: 0.1,
        },
    ));

    // cube
    commands.spawn((
        Mesh3d(meshes.add(Cuboid::default())),
        MeshMaterial3d(materials.add(Color::srgb(0.8, 0.7, 0.6))),
        Transform::from_xyz(0.0, 0.0, 0.0),
        Rotates,
    ));
    // light
    commands.spawn(DirectionalLight {
        illuminance: 1_000.,
        ..default()
    });
}

#[derive(Component)]
struct Rotates;

/// Rotates any entity around the x and y axis
fn rotate(time: Res<Time>, mut query: Query<&mut Transform, With<Rotates>>) {
    for mut transform in &mut query {
        transform.rotate_x(0.55 * time.delta_secs());
        transform.rotate_z(0.15 * time.delta_secs());
    }
}

fn main() {
    App::new()
        .add_plugins((
            DefaultPlugins.set(WindowPlugin {
                primary_window: Some(Window {
                    resolution: Vec2::splat(400.0).into(),
                    title: "cube".into(),
                    ..default()
                }),
                ..default()
            }),
            OldTvPlugin,
        ))
        .add_systems(Startup, setup)
        .add_systems(Update, rotate)
        .run();
}
