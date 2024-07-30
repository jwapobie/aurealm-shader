#version 460 compatibility

uniform mat4 dhProjection;

out vec4 blockColor;
out vec2 lightMapCoords;
out vec4 viewPos;

void main() {
    blockColor = gl_Color;
    lightMapCoords = (gl_TextureMatrix[1] * gl_MultiTexCoord1).xy;
    viewPos = (gl_ModelViewMatrix * gl_Vertex);
    gl_Position = ftransform();
}