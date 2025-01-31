#import bevy_core_pipeline::fullscreen_vertex_shader::FullscreenVertexOutput

@group(0) @binding(0) var screen_texture: texture_2d<f32>;
@group(0) @binding(1) var texture_sampler: sampler;
struct OldTvSettings {
    screen_shape_factor: f32,
    rows: f32,
    brightness: f32,
    edges_transition_size: f32,
    channels_mask_min: f32,
#ifdef SIXTEEN_BYTE_ALIGNMENT
    // WebGL2 structs must be 16 byte aligned.
    _webgl2_padding: vec3<f32>
#endif
}
@group(0) @binding(2) var<uniform> settings: OldTvSettings;

fn apply_screen_shape(uv_: vec2<f32>, factor: f32) -> vec2<f32> {
    var uv = uv_ - vec2(0.5, 0.5);
    uv = uv * (uv.yx * uv.yx * factor + 1.0);
    return uv + vec2(0.5, 0.5);
}

fn pixelate(uv: vec2<f32>, size: vec2<f32>) -> vec2<f32> {
    return floor(uv * size) / size;
}

fn get_texture_color(uv: vec2<f32>) -> vec4<f32> {
    return textureSample(screen_texture, texture_sampler, uv);
}

fn apply_pixel_rows(color: vec4<f32>, uv: vec2<f32>, rows: f32) -> vec4<f32> {
    var f = abs(fract(uv.y * rows) - 0.5) * 2.;
    f = f * f;
    return mix(color, vec4<f32>(0., 0., 0., 1.), f);
}

fn apply_pixel_cols(color: vec4<f32>, uv: vec2<f32>, cols: f32) -> vec4<f32> {
    var f = abs(fract(uv.x * cols * 3.) - 0.5) * 2.;
    f = f * f;

    let channel = u32(fract(uv.x * cols) * 3.0);
    let channels_mask_min = settings.channels_mask_min;

    var channel_mask = vec4(1.0, channels_mask_min, channels_mask_min, 1.0);
    if channel == 1u {
        channel_mask = vec4(channels_mask_min, 1.0, channels_mask_min, 1.0);
    } else if channel == 2u {
        channel_mask = vec4(channels_mask_min, channels_mask_min, 1.0, 1.0);
    }

    return mix(color * channel_mask, vec4<f32>(0., 0., 0., 1.), f);
}

// Get the aspect ratio if all you have is the uv coordinates.
fn aspect_ratio(uv: vec2<f32>) -> f32 {
    return dpdy(uv.y) / dpdx(uv.x);
}

fn apply_screen_edges(color: vec4<f32>, uv: vec2<f32>, ratio: f32) -> vec4<f32> {
    let edges_transition_size = settings.edges_transition_size;
    let edge_x = min(uv.x / edges_transition_size, (1.0 - uv.x) / edges_transition_size);
    let edge_y = min(uv.y / edges_transition_size / ratio, (1.0 - uv.y) / edges_transition_size / ratio);

    let edge = vec2(
        max(edge_x, 0.0),
        max(edge_y, 0.0),
    );
    var f = min(edge.x, edge.y);
    f = min(f, 1.0);

    return vec4(color.xyz * f, 1.0);
} 

fn apply_brightness(color: vec4<f32>) -> vec4<f32> {
    return color * vec4(vec3(settings.brightness), 1.0);
}

@fragment
fn fragment(in: FullscreenVertexOutput) -> @location(0) vec4<f32> {
    // let ratio = 3.0;
    let ratio = aspect_ratio(in.uv);
    let uv = apply_screen_shape(in.uv, settings.screen_shape_factor);
    let rows = settings.rows;
    
    let cols = rows * ratio;

    let texture_uv = pixelate(uv, vec2(cols, rows));

    var color = get_texture_color(texture_uv);

    color = apply_pixel_rows(color, uv, rows);
    color = apply_pixel_cols(color, uv, cols);

    color = apply_brightness(color);
    color = apply_screen_edges(color, uv, ratio);

    return color;
    // return vec4(ratio/ 2, 0, 0, 1);
}
