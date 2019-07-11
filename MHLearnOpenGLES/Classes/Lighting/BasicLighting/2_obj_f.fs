
varying lowp vec3 Normal;
varying lowp vec3 FragPos;

uniform lowp vec3 lightPos;
uniform lowp vec3 lightColor;
uniform lowp vec3 objectColor;

void main()
{
    lowp float ambientStrength = 0.1;
    lowp vec3 ambient = ambientStrength * lightColor;
    
    // diffuse
    lowp vec3 norm = normalize(Normal);
    lowp vec3 lightDir = normalize(lightPos - FragPos);
    lowp float diff = max(dot(norm, lightDir), 0.0);
    lowp vec3 diffuse = diff * lightColor;
    
    lowp vec3 result = (ambient + diffuse) * objectColor;
    gl_FragColor = vec4(result, 1.0);
}

