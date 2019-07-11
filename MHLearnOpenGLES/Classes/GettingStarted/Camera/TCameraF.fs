varying lowp vec2 TexCoord;// 从顶点着色器传来的输入变量（名称相同、类型相同）

uniform sampler2D texture1;
uniform sampler2D texture2;

void main()
{
    gl_FragColor = mix(texture2D(texture1,TexCoord),texture2D(texture2,TexCoord),0.2);
}

