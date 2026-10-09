#version 330 compatibility

uniform sampler2D colortex0;
uniform sampler2D colortex1;
uniform sampler2D colortex2;
uniform sampler2D depthtex0;

uniform vec3 shadowLightPosition;
uniform mat4 gbufferModelViewInverse;

const vec3 blocklightColor = vec3(1.0, 0.5, 0.08);
const vec3 skylightColor = vec3(0.05, 0.15, 0.3);
const vec3 sunlightColor = vec3(1.0);
const vec3 ambientColor = vec3(0.1);

in vec2 texcoord;

/* RENDERTARGETS: 0 */
layout(location = 0) out vec4 color;

void main() {
    color = texture(colortex0, texcoord);

    // Convert the texture colour to linear space.
    color.rgb = pow(max(color.rgb, vec3(0.0)), vec3(2.2));

    float depth = texture(depthtex0, texcoord).r;

    // Apply custom lighting only to geometry, not the sky.
    if (depth < 1.0) {
        vec2 lightmap = texture(colortex1, texcoord).xy;

        vec3 encodedNormal = texture(colortex2, texcoord).rgb;
        vec3 normal = normalize((encodedNormal - 0.5) * 2.0);

        vec3 lightVector = normalize(shadowLightPosition);
        vec3 worldLightVector = normalize(
            mat3(gbufferModelViewInverse) * lightVector
        );

        vec3 blocklight = lightmap.x * blocklightColor;
        vec3 skylight = lightmap.y * skylightColor;
        vec3 ambient = ambientColor;

        vec3 sunlight = sunlightColor
            * clamp(dot(worldLightVector, normal), 0.0, 1.0)
            * lightmap.y;

        color.rgb *= blocklight + skylight + ambient + sunlight;
    }

    // Convert back to display colour space.
    color.rgb = pow(max(color.rgb, vec3(0.0)), vec3(1.0 / 2.2));
}