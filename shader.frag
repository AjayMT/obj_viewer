#version 110

varying vec3 vLightPosition;
varying vec3 vNormal;
varying vec3 vPosition;

void main(void)
{
  float shininess = 30.0;
  vec3 vectorToLightSource = normalize(vLightPosition - vPosition);
  float diffuseLightWeighting = max(dot(vNormal, vectorToLightSource), 0.0);
  vec3 reflectionVector = normalize(reflect(-vectorToLightSource, vNormal));
  vec3 viewVectorEye = -normalize(vPosition);
  float rdotv = max(dot(reflectionVector, viewVectorEye), 0.0);
  float specularLightWeighting = pow(rdotv, shininess);

  gl_FragColor = vec4(vec3(0.0, 0.0, 0.0)
                      + diffuseLightWeighting * vec3(1.0, 0.0, 0.0)
                      + specularLightWeighting * vec3(1.0, 1.0, 1.0),
                      1.0);
}
