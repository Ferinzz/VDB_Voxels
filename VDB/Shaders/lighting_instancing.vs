#version 330

// Input vertex attributes
in vec3 vertexPosition;
in vec2 vertexTexCoord;
in vec3 vertexNormal;
in vec3 vertexColor;      // Not required

in mat4 instanceTransform;

// Input uniform values
uniform mat4 mvp;
uniform mat4 matNormal;

// Output vertex attributes (to fragment shader)
out vec4 fragColor;
out vec2 fragTexCoord;

// NOTE: Add here your custom variables

void main()
{
	fragTexCoord = vertexTexCoord;
    vec4 PosColor = normalize(instanceTransform[3]);
    // Calculate final vertex position, note that we multiply mvp by instanceTransform
    gl_Position = mvp*instanceTransform*vec4(vertexPosition, 1.0);
	//fragColor = vec4(vertexColor, 1.0);
    fragColor = vec4(PosColor[0],PosColor[1],PosColor[2], 1.0);
}