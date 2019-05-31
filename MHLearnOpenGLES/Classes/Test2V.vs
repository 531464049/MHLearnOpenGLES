// 顶点着色器
attribute vec4 position;
attribute vec2 textCoordinate;
uniform float rotate;

varying lowp vec2 varyTextCoord;

void main() 
{
    varyTextCoord = textCoordinate;
    
    mat4 rotationMatrix = mat4(cos(rotate), -sin(rotate), 0.0, 0.0,
                               sin(rotate),  cos(rotate), 0.0, 0.0,
                               0.0,          0.0,         1.0, 0.0,
                               0.0,          0.0,         0.0, 1.0);
    
    gl_Position = position * rotationMatrix;
}
