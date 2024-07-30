#version 460 compatibility

uniform sampler2D lightmap;
uniform sampler2D depthtex0;

uniform mat4 gbufferModelViewInverse;
uniform mat4 gbufferProjectionInverse;

uniform float viewHeight;
uniform float viewWidth;
uniform float near;
uniform float far;
uniform float dhNearPlane;
uniform float dhFarPlane;
uniform float fogStart;
uniform float fogEnd;

layout(location=0) out vec4 outColor0;

in vec4 blockColor;
in vec2 lightMapCoords;
in vec4 viewPos;

//functions
float linearizeDepth(float depth, float near, float far) {
    return (near * far) / (depth * (near - far) + far);
}

#include "/lib/fog.glsl"

void main() {
    vec3 lightColor = pow(texture(lightmap,lightMapCoords).rgb, vec3(2.2));

    vec4 outputColorData = blockColor;
    vec3 outputColor = pow(outputColorData.rgb, vec3(2.2)) * lightColor;
    float transparency = outputColorData.a;
    if (transparency < .01) {
        discard;
    }


    vec2 texCoord = gl_FragCoord.xy / vec2(viewWidth,viewHeight);
    float depth = texture(depthtex0,texCoord).r;
    float dhDepth = gl_FragCoord.z;
    float depthLinear = linearizeDepth(depth,near,far*4);
    float dhDepthLinear = linearizeDepth(dhDepth,dhNearPlane,dhFarPlane);
    if (depthLinear < dhDepthLinear && depth != 1) {
        discard;
    }
    outColor0 = pow(vec4(outputColor, transparency), vec4(1/2.2));
    vec4 worldPos = gbufferModelViewInverse * viewPos;
    outColor0.rgb = applyFog(outColor0.rgb, 0.0, 100, worldPos);
    float dist;
	dist = length(worldPos.xz);
    outColor0.a *= smoothstep(min(fogStart, fogEnd-64), fogEnd, dist);;
}