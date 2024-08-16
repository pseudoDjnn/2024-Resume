precision mediump float;

uniform float uAudioFrequency;
uniform float uTimeAnimation;
uniform float uTime;
// uniform float uWaveElevation;
// uniform float uWaveSpeed;

attribute float aRandom;

varying float vRandom;
// varying float vElevation;
varying vec3 vNormal;
varying vec3 vPosition;
varying vec2 vUv;

#include ../includes/effects/terrainGeneration.glsl

void main() {
  // Base Postion
  float shift = 0.01;
  vec4 modelPosition = modelMatrix * vec4(position, 1.0);
  vec3 modelPositionAlpha = modelPosition.xyz + vec3(shift, 0.0, 0.0);
  vec3 modelPositionBeta = modelPosition.xyz + vec3(0.0, 0.0, -shift);

  // Compute Normal
  // 
  vec3 alphaNeighbor = normalize(modelPositionAlpha - modelPosition.xyz);
  vec3 betaNeighbor = normalize(modelPositionBeta - modelPosition.xyz);
  // 
  // 
  vec3 computeNormal = cross(alphaNeighbor, betaNeighbor);
  // 
// 
  // Glitching effect
  // float glitchTime = uAudioFrequency * 0.01 - modelPosition.y * 0.2;
  // float stuttering = sin(glitchTime) + sin(glitchTime * 3.55) + sin(glitchTime * 8.89);
  // stuttering /= 3.0;
  // stuttering *= uAudioFrequency * 0.1;
  // stuttering *= 0.34;
  // modelPosition.x += (random2D(modelPosition.xz * uAudioFrequency) - 0.5) * stuttering / 3.0;
  // modelPosition.z += (random2D(modelPosition.zx * uAudioFrequency) - 0.5) * stuttering / 3.0;

  // Final Position
  vec4 viewPosition = viewMatrix * modelPosition;
  vec4 projectedPosition = projectionMatrix * viewPosition;
  gl_Position = projectedPosition;

  // Varyings
  // vRandom = aRandom;
  // vElevation = elevation;
  vNormal = computeNormal;
  // vPosition = modelPosition.xyz;
  vUv = uv;
}