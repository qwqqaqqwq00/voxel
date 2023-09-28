struct VertexInput {
	@location(0) position: vec3<f32>,
	@location(1) normal: vec3<f32>,
	@location(2) color: vec3<f32>,
	@location(3) uv: vec2<f32>,
};

struct InstanceInput {
	@location(4) model0: vec4<f32>,
	@location(5) model1: vec4<f32>,
	@location(6) model2: vec4<f32>,
	@location(7) model3: vec4<f32>
}

struct VertexOutput {
	@builtin(position) position: vec4<f32>,
	@location(0) color: vec3<f32>,
	@location(1) normal: vec3<f32>,
	@location(2) uv: vec2<f32>,
};

struct MyUniforms {
	projectionMatrix: mat4x4<f32>,
	viewMatrix: mat4x4<f32>,
	modelMatrix: mat4x4<f32>,
	color: vec4<f32>,
	time: f32,
};


struct LightingUniforms {
	directions: array<vec4<f32>, 2>,
	colors: array<vec4<f32>, 2>,
}

@group(0) @binding(0) var<uniform> uMyUniforms: MyUniforms;
@group(0) @binding(1) var baseColorTexture: texture_2d<f32>;
@group(0) @binding(2) var textureSampler: sampler;
@group(0) @binding(3) var<uniform> uLighting: LightingUniforms;

@vertex
fn vs_main(in: VertexInput, inst: InstanceInput) -> VertexOutput {
	var out: VertexOutput;
	var model_mat = mat4x4<f32>(inst.model0, inst.model1, inst.model2, inst.model3);
	out.position = uMyUniforms.projectionMatrix * uMyUniforms.viewMatrix * uMyUniforms.modelMatrix * model_mat * vec4<f32>(in.position, 1.0); //
	out.normal = (uMyUniforms.modelMatrix * vec4<f32>(in.normal, 0.0)).xyz;
	out.color = in.color;
	out.uv = in.uv;
	return out;
}

@fragment
fn fs_main(in: VertexOutput) -> @location(0) vec4f {
	// Compute shading
	let normal = normalize(in.normal);
	var shading = vec3<f32>(0.0);
	for (var i: i32 = 0; i < 2; i++) {
		let direction = normalize(uLighting.directions[i].xyz);
		let color = uLighting.colors[i].rgb;
		shading += max(0.0, dot(direction, normal)) * color;
	}
	
	// Sample texture
	let baseColor = textureSample(baseColorTexture, textureSampler, in.uv).rgb;

	// Combine texture and lighting
	let color = baseColor * shading;

	// Gamma-correction
	let corrected_color = pow(color, vec3<f32>(2.2));
	return vec4<f32>(corrected_color, uMyUniforms.color.a);
}
