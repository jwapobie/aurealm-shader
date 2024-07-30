#ifndef FOG_INCLUDE
#define FOG_INCLUDE

uniform vec3 cameraPosition;
uniform vec3 skyColor;
float height_fog_falloff = 80;
float height_fog_start = 64;
#ifdef DISTANT_HORIZONS
	uniform int dhRenderDistance;
#endif

float getBorderFogStrength(float fogStart, float fogEnd, vec4 worldPos) {
	#ifdef DISTANT_HORIZONS
		fogStart = dhRenderDistance * 0.8;
		fogEnd = dhRenderDistance * 0.95;
	#endif
	float dist;
	dist = max(length(worldPos.xz), abs(worldPos.y));
	return smoothstep(fogStart, fogEnd, dist);
}

float getFogStrength(float fogStart, float fogEnd, vec4 worldPos) {
	fogEnd = fogEnd / 2;
	float dist;
	dist = max(length(worldPos.xz), abs(worldPos.y));
	return clamp((dist + min(fogStart, -100)) / fogEnd, 0, 0.8);
}

float getHeightFogFactor(float altitude) {
	return pow(1 - clamp((altitude - height_fog_start) / height_fog_falloff, 0, 1), 2);
}

float getHeightFogStrength(float fogStart, float fogEnd, vec4 worldPos) {
	float baseHeightFog = getHeightFogFactor(worldPos.y + cameraPosition.y);
	float adjustedHeightFog = baseHeightFog * (clamp((length(worldPos.xyz)-50) / 1000, 0, 1));
	return adjustedHeightFog;
}

vec3 applyFog(vec3 input_col, float fogStart, float fogEnd, vec4 worldPos) {
	#ifdef DISTANT_HORIZONS
		fogEnd = dhRenderDistance;
	#endif
	float fog_str = min(getHeightFogStrength(fogStart, fogEnd, worldPos) + getBorderFogStrength(fogStart, fogEnd, worldPos), 1.0);
	vec4 height_fog = vec4(gl_Fog.color.rgb, fog_str);
	vec4 sky_fog = vec4(skyColor.rgb, getFogStrength(fogStart, fogEnd, worldPos));
	vec3 input_col_with_sky = input_col * (1-sky_fog.a) + (sky_fog.rgb * 1.2 + gl_Fog.color.rgb) * sky_fog.a * 0.5;
	return mix(input_col_with_sky, height_fog.rgb, height_fog.a);
}

vec3 applyFog(vec3 input_col, float fogStart, float fogEnd) {
	vec4 fragPos = vec4((gl_FragCoord.xy / vec2(viewWidth, viewHeight)) * 2.0f - 1.0f, gl_FragCoord.z * 2.0f - 1.0f, 1.0f);
	fragPos = gbufferProjectionInverse * fragPos;
	fragPos /= fragPos.w;

	float distInHeightFog = 0;
	vec4 worldPos = gbufferModelViewInverse * fragPos;
	return applyFog(input_col, fogStart, fogEnd, worldPos);
}

float getCloudFogStrength(float fogStart, float fogEnd) {
	vec4 fragPos = vec4((gl_FragCoord.xy / vec2(viewWidth, viewHeight)) * 2.0f - 1.0f, gl_FragCoord.z * 2.0f - 1.0f, 1.0f);
	fragPos = gbufferProjectionInverse * fragPos;
	fragPos /= fragPos.w;
	vec4 worldPos = gbufferModelViewInverse * fragPos;

	return getBorderFogStrength(fogStart, fogEnd, worldPos);
}

#endif
