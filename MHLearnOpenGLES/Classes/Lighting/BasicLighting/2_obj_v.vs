
attribute vec3 aPos;
attribute vec3 aNormal;

uniform mat4 model;
uniform mat4 view;
uniform mat4 projection;

varying lowp vec3 Normal;
varying lowp vec3 FragPos;

void main()
{
    FragPos = vec3(model * vec4(aPos,1.0));
    Normal = aNormal;
    
    gl_Position = projection * view * model * vec4(aPos,1.0);
}
