#define PI 3.1415926535897932384626433832795
#define TAU  6.28318530718
#define NUM_OCTAVES 5

precision mediump float;

uniform float uAudioFrequency;
uniform float uFrequencyData[256];

uniform float uTimeAnimation;
uniform float uTime;

attribute float aRandom;

varying float vRandom;
varying vec3 vNormal;
varying vec3 vPosition;
varying vec2 vUv;

#include ../includes/effects/fbm.glsl

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

  // Glitching effect
  float glitchTime = uTime - modelPosition.y;
  float stuttering = sin(glitchTime) + sin(glitchTime * 3.55) + sin(glitchTime * 8.89);
  stuttering /= 3.0;
  stuttering = smoothstep(0.3, 1.0, stuttering);
  stuttering *= 0.21;
  modelPosition.x += (randomValue(modelPosition.xzy + uTime) - 0.5) * stuttering;
  modelPosition.z += (randomValue(modelPosition.yzx + uTime) - 0.5) * stuttering;

  // Final Position
  vec4 viewPosition = viewMatrix * modelPosition;
  vec4 projectedPosition = projectionMatrix * viewPosition;
  gl_Position = projectedPosition;

  // Varyings
  // vRandom = aRandom;
  // vElevation = elevation;
  vNormal = computeNormal;
  vPosition = modelPosition.xyz;
  vUv = uv;
}