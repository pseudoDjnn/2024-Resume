uniform mat4 projectionMatrix;
uniform mat4 viewMatrix;
uniform mat4 modelMatrix;
uniform vec2 uFrequency;
uniform float uTime;

attribute vec3 position;
attribute float aRandom;

varying float vRandom;

void main() {
  vec4 modelPosition = modelMatrix * vec4(position, 1.0);

  modelPosition.z += sin(aRandom * uFrequency.x - uTime) * -13.0;
  modelPosition.z += sin(aRandom * uFrequency.y + -uTime) * -13.0;
  // modelPosition.z += sin(modelPosition.x * uFrequency.x) * 0.1;

  vec4 viewPosition = viewMatrix * modelPosition;
  vec4 projectedPosition = projectionMatrix * viewPosition;

  gl_Position = projectedPosition;

  vRandom = aRandom;
}