#import bevy_pbr::mesh_view_bindings


@group(1) @binding(0)
var texture: texture_2d<f32>;

@group(1) @binding(1)
var our_sampler: sampler;

@group(1) @binding(2)
var<uniform> screen_shape_factor: f32;

@group(1) @binding(3)
var<uniform> rows: f32;

@group(1) @binding(4)
var<uniform> brightness: f32;

@group(1) @binding(5)
var<uniform> edges_transition_size: f32;

@group(1) @binding(6)
var<uniform> channels_mask_min: f32;

fn get_uv(pos: vec2<f32>) -> vec2<f32> {
    return pos / vec2(view.width, view.height);
}

fn apply_screen_shape(uv: vec2<f32>, factor: f32) -> vec2<f32> {
    let uv = uv - vec2(0.5, 0.5);
    let uv = uv * (uv.yx * uv.yx * factor + 1.0);
    return uv + vec2(0.5, 0.5);
}

fn pixelate(uv: vec2<f32>, size: vec2<f32>) -> vec2<f32> {
    return floor(uv * size) / size;
}

fn get_texture_color(uv: vec2<f32>) -> vec4<f32> {
    return textureSample(texture, our_sampler, uv);
}

fn apply_pixel_rows(color: vec4<f32>, uv: vec2<f32>, rows: f32) -> vec4<f32> {
    let f = abs(fract(uv.y * rows) - 0.5) * 2.;
    let f = f * f;
    return mix(color, vec4<f32>(0., 0., 0., 1.), f);
}

fn apply_pixel_cols(color: vec4<f32>, uv: vec2<f32>, cols: f32) -> vec4<f32> {
    let f = abs(fract(uv.x * cols * 3.) - 0.5) * 2.;
    let f = f * f;

    let channel = u32(fract(uv.x * cols) * 3.0);

    var channel_mask = vec4(1.0, channels_mask_min, channels_mask_min, 1.0);
    if channel == 1u {
        channel_mask = vec4(channels_mask_min, 1.0, channels_mask_min, 1.0);
    } else if channel == 2u {
        channel_mask = vec4(channels_mask_min, channels_mask_min, 1.0, 1.0);
    }

    let color = color * channel_mask;
    return mix(color, vec4<f32>(0., 0., 0., 1.), f);
}

fn apply_screen_edges(color: vec4<f32>, uv: vec2<f32>) -> vec4<f32> {
    let ratio = view.width / view.height;

    let edge_x = min(uv.x / edges_transition_size, (1.0 - uv.x) / edges_transition_size);
    let edge_y = min(uv.y / edges_transition_size / ratio, (1.0 - uv.y) / edges_transition_size / ratio);

    let edge = vec2(
        max(edge_x, 0.0),
        max(edge_y, 0.0),
    );
    let f = min(edge.x, edge.y);
    let f = min(f, 1.0);

    return vec4(color.xyz * f, 1.0);
} 

fn applye_brightness(color: vec4<f32>) -> vec4<f32> {
    return color * vec4(vec3(brightness), 1.0);
}

@fragment
fn fragment(
    @builtin(position) position: vec4<f32>,
    #import bevy_sprite::mesh2d_vertex_output
) -> @location(0) vec4<f32> {
    let uv = get_uv(position.xy);
    let uv = apply_screen_shape(uv, screen_shape_factor);
    
    let cols = rows * view.width / view.height;

    let texture_uv = uv;
    let texture_uv = pixelate(texture_uv, vec2(cols, rows));

    let color = get_texture_color(texture_uv);

    let color = apply_pixel_rows(color, uv, rows);
    let color = apply_pixel_cols(color, uv, cols);

    let color = applye_brightness(color);
    let color = apply_screen_edges(color, uv);

    return color;
}
