uniform vec2 uFrequency;
uniform vec2 uResolution;
uniform vec2 uWaveFrequency;

uniform float uAudioFrequency;
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
#include ../includes/effects/simplexNoise3D.glsl

mat2 rotate2d(float angle) {
  return mat2(cos(angle), -sin(angle), sin(angle), cos(angle));
}

void main() {
  // Base Postion
  float shift = 0.01;
  vec4 modelPosition = modelMatrix * vec4(position, 1.0);
  vec3 modelPositionAlpha = modelPosition.xyz + vec3(shift, 0.0, 0.0);
  vec3 modelPositionBeta = modelPosition.xyz + vec3(0.0, 0.0, -shift);

// Audio levels used with perlin noise
  float noise = 5.0 * cnoise(vec3(position.zx * 3.0, uTime));
  float displacementInteger = fract(sin(uAudioFrequency * 100000.0)) * (noise / 13.0);
  float displacementFraction = fract(displacementInteger);

  float generateNoise = fract(sin(noise) * 1.0);
  generateNoise = cnoise(vec3(displacementInteger));
  generateNoise = mix(cnoise(vec3(displacementInteger)), cnoise(vec3(displacementInteger + 1.0)), displacementFraction);
  generateNoise = mix(cnoise(vec3(displacementInteger)), cnoise(vec3(displacementInteger + 1.0)), smoothstep(0.0, 1.0, displacementFraction));

  displacementInteger = smoothstep(0.0, 1.0, displacementFraction);

  float elevation = waveElevation(modelPosition.xyz);
  modelPosition.y += elevation * (generateNoise * 0.2);
  modelPositionAlpha.y += waveElevation(modelPositionAlpha);
  modelPositionBeta.y += waveElevation(modelPositionBeta);

  // Compute Normal
  vec3 alphaNeighbor = normalize(modelPositionAlpha - modelPosition.xyz);
  vec3 betaNeighbor = normalize(modelPositionBeta - modelPosition.xyz);
  vec3 computeNormal = cross(alphaNeighbor, betaNeighbor);

  // modelPosition.y += elevation * aRandom;
  // modelPosition.x /= sin(-aRandom * aRandom * 0.01 * (uFrequency.x - uTime * smoothstep(-0.144, 0.987, -uAudioFrequency * 0.002) * 0.001)) * -21.8;
  // modelPosition.z += sin(-aRandom * aRandom * 0.01 * (uFrequency.y - uTimeAnimation * smoothstep(-0.212, 1.188, uAudioFrequency * 0.05)) * 0.02) * 13.21;

  // Glitching effect
  float glitchTime = uTime - modelPosition.y * 0.03;
  float stuttering = sin(glitchTime * generateNoise) + sin(glitchTime * 3.55) + sin(glitchTime * 8.89);
  stuttering /= 3.0;
  stuttering = smoothstep(0.3, 1.0, stuttering);
  stuttering *= 0.21;
  modelPosition.x += (random2D(modelPosition.xz * uAudioFrequency * uTime) - 0.5) * stuttering;
  modelPosition.z += (random2D(modelPosition.zx * generateNoise * uTimeAnimation) - 0.5) * stuttering;

  // Final Position
  vec4 viewPosition = viewMatrix * modelPosition;
  vec4 projectedPosition = projectionMatrix * viewPosition;
  gl_Position = projectedPosition;

  // Point size
  // gl_PointSize = 0.13 * uResolution.y;
  // gl_PointSize *= (1.0 / -viewPosition.z);

  // Varyings
  vRandom = aRandom;
  // vElevation = elevation;
  vNormal = computeNormal;
  vPosition = modelPosition.xyz;
  vUv = uv;

}