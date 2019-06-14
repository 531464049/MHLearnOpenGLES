
attribute vec3 aPos;
attribute vec3 aColor;
varying lowp vec4 vertexColor;

void main()
{
    gl_Position = vec4(aPos,1.0);
    vertexColor = vec4(aColor,1.0);
}
