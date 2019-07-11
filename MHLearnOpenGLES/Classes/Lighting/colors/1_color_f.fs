
uniform lowp vec3 objectColor;
uniform lowp vec3 lightColor;

void main()
{
    gl_FragColor = vec4(objectColor * lightColor, 1.0);
//    gl_FragColor = vec4(1.0, 0.5, 0.31, 1.0);
}

