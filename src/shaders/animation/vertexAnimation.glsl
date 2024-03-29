uniform vec2 uFrequency;
uniform vec2 uResolution;
uniform vec2 uWaveFrequency;

uniform float uTimeAnimation;
uniform float uTime;
uniform float uWaveElevation;
uniform float uWaveSpeed;

attribute float aRandom;

varying float vRandom;
varying float vElevation;
varying vec3 vNormal;
varying vec3 vPosition;
varying vec2 vUv;

#include ../includes/effects/perlin.glsl
#include ../includes/effects/random2D.glsl
#include ../includes/effects/waveElevation.glsl

void main() {
  // Base Postion
  float shift = 0.01;
  vec4 modelPosition = modelMatrix * vec4(position, 1.0);
  vec3 modelPositionAlpha = modelPosition.xyz + vec3(shift, 0.0, 0.0);
  vec3 modelPositionBeta = modelPosition.xyz + vec3(0.0, 1.0, shift);

  float elevation = waveElevation(modelPosition.xyz);
  modelPosition.y += elevation;
  modelPositionAlpha.y += waveElevation(modelPositionAlpha);
  modelPositionBeta.y += waveElevation(modelPositionBeta);

  // Compute Normal
  vec3 alphaNeighbor = normalize(modelPositionAlpha - modelPosition.xyz);
  vec3 betaNeighbor = normalize(modelPositionBeta - modelPosition.xyz);
  vec3 computeNormal = cross(alphaNeighbor, betaNeighbor);

  // modelPosition.y += elevation * aRandom;
  modelPosition.x += sin(aRandom * uFrequency.x - uTimeAnimation) * -21.8;
  modelPosition.z += sin(aRandom * uFrequency.y - uTimeAnimation) * 13.0;

  // Glitching effect
  float glitchTime = uTime - (modelPosition.y * 0.2);
  float stuttering = sin(glitchTime) + sin(glitchTime * 1.89) + sin(glitchTime * 2.34);
  stuttering /= 3.0;
  stuttering = smoothstep(0.8, 1.0, stuttering);
  stuttering *= 0.34;
  modelPosition.x += (random2D(modelPosition.xz + uTime) - 0.5) * stuttering;
  modelPosition.z += (random2D(modelPosition.zx + uTime) - 0.5) * stuttering;

  // Final Position
  vec4 viewPosition = viewMatrix * modelPosition;
  vec4 projectedPosition = projectionMatrix * viewPosition;
  gl_Position = projectedPosition;

  // Point size
  gl_PointSize = 0.13 * uResolution.y;
  gl_PointSize *= (1.0 / -viewPosition.z);

  // Varyings
  vRandom = aRandom;
  vElevation = elevation;
  vNormal = computeNormal;
  vPosition = modelPosition.xyz;
  vUv = uv;

}