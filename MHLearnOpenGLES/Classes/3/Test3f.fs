
// 片元着色器
varying highp vec4 varyTextCoord;

void main()
{
    gl_FragColor = varyTextCoord;
}
