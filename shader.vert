#version 110

varying vec3 vLightPosition;
varying vec3 vNormal;
varying vec3 vPosition;

void main()
{
  vLightPosition = gl_LightSource[0].position.xyz;
  vNormal = normalize(gl_NormalMatrix * gl_Normal);
  vec4 tmp = gl_ModelViewMatrix * gl_Vertex;
  vPosition = tmp.xyz / tmp.w;
  gl_Position = ftransform();
}
