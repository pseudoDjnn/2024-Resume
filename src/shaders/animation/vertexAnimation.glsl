// uniform mat4 projectionMatrix;
// uniform mat4 viewMatrix;
// uniform mat4 modelMatrix;

uniform vec2 uFrequency;
uniform vec2 uWaveFrequency;

uniform float uTimeAnimation;
uniform float uWaveElevation;
uniform float uWaveSpeed;

// attribute vec3 position;
attribute float aRandom;
// attribute vec2 uv;

varying float vRandom;
varying float vElevation;
varying vec2 vUv;

#include ../includes/perlin.glsl

void main() {
  vec4 modelPosition = modelMatrix * vec4(position, 1.0);

  float elevation = sin(modelPosition.x * uWaveFrequency.x + uTimeAnimation * uWaveSpeed) * sin(modelPosition.y * uWaveFrequency.y + uTimeAnimation * uWaveSpeed) * uWaveElevation;
  modelPosition.y += elevation * aRandom;
  modelPosition.z += sin(aRandom * uFrequency.x - uTimeAnimation) * -3.0;
  modelPosition.z += sin(aRandom * uFrequency.y - uTimeAnimation) * -3.0;

  for (float i = 1.0; i <= 4.0; i++) {
    elevation -= abs(cnoise(vec3(modelPosition.xz * 3.0 * i, uTimeAnimation * 0.02)) * 0.15 / i);

  }

  modelPosition.y += elevation;

  // vec4 viewPosition = viewMatrix * modelPosition;
  // vec4 projectedPosition = projectionMatrix * viewPosition;

  // gl_Position = projectedPosition;
  gl_Position = projectionMatrix * viewMatrix * modelPosition;

// Varyings
  vRandom = aRandom;
  vUv = uv;
  vElevation = elevation;
}