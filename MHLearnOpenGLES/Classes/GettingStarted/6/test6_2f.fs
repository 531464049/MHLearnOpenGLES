varying lowp vec2 TexCoord;// 从顶点着色器传来的输入变量（名称相同、类型相同）
uniform sampler2D ourTexture;
void main()
{
    gl_FragColor = texture2D(ourTexture,TexCoord);
}

