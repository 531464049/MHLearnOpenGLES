
// 顶点着色器
attribute vec4 position;
attribute vec4 textCoordinate;

uniform mat4 projectionMatrix;
uniform mat4 modelViewMatrix;

varying highp vec4 varyTextCoord;

void main()
{
    varyTextCoord = textCoordinate;
    
    mat4 rotationMatrix = mat4(cos(0.0), -sin(0.0), 0.0, 0.0,
                               sin(0.0),  cos(0.0), 0.0, 0.0,
                               0.0,          0.0,         1.0, 0.0,
                               0.0,          0.0,         0.0, 1.0);
    gl_Position = projectionMatrix * modelViewMatrix * position;
}

