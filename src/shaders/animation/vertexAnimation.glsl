uniform vec2 uFrequency;
uniform vec2 uWaveFrequency;

uniform float uTimeAnimation;
uniform float uTime;
uniform float uWaveElevation;
uniform float uWaveSpeed;

attribute float aRandom;

varying float vRandom;
varying float vElevation;
varying vec2 vUv;
varying vec3 vPosition;
varying vec3 vNormal;

#include ../includes/perlin.glsl
#include ../includes/random2D.glsl

void main() {
  vec4 modelPosition = modelMatrix * vec4(position, 1.0);

  // Glitching effect
  float glitchTime = uTime - modelPosition.y;
  float stuttering = sin(glitchTime) + sin(glitchTime * 3.55) + sin(glitchTime * 8.89);
  stuttering /= 3.0;
  stuttering = smoothstep(0.3, 1.0, stuttering);
  stuttering *= 0.34;

  float elevation = sin(modelPosition.x * uWaveFrequency.x + uTimeAnimation * uWaveSpeed) * sin(modelPosition.y * uWaveFrequency.y + uTimeAnimation * uWaveSpeed) * uWaveElevation;
  modelPosition.y += elevation * aRandom;
  modelPosition.x += sin(aRandom * uFrequency.x - uTimeAnimation) * -0.8;
  modelPosition.z += sin(aRandom * uFrequency.y - uTimeAnimation) * 21.0;

  for (float i = 1.0; i <= 4.0; i++) {
    elevation -= abs(cnoise(vec3(modelPosition.xz * 3.0 * i, uTimeAnimation * 0.2)) * 0.21 / i);

  }

  // modelPosition.y += elevation;
  modelPosition.x += (random2D(modelPosition.xz + uTime) - 0.5) * stuttering;
  modelPosition.z += (random2D(modelPosition.zx + uTime) - 0.5) * stuttering;

  gl_Position = projectionMatrix * viewMatrix * modelPosition;

  // Model normal
  vec4 modelNormal = modelMatrix * vec4(normal, 0.0);

// Varyings
  vRandom = aRandom;
  vUv = uv;
  vElevation = elevation;
  vPosition = modelPosition.xyz;
  vNormal = modelNormal.xyz;

}