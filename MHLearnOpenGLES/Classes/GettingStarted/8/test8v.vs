
attribute vec3 aPos;
attribute vec2 aTexCoord;

uniform mat4 model;
uniform mat4 view;
uniform mat4 projection;

varying lowp vec2 TexCoord;

void main()
{
    gl_Position = projection * view * model * vec4(aPos,1.0);
//    gl_Position = view * model * vec4(aPos,1.0);
    TexCoord = aTexCoord;
}
