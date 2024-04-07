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

void main() {
  // Base Postion
  float shift = 0.01;
  vec4 modelPosition = modelMatrix * vec4(position, 1.0);
  vec3 modelPositionAlpha = modelPosition.xyz + vec3(shift, 0.0, 0.0);
  vec3 modelPositionBeta = modelPosition.xyz + vec3(0.0, 0.0, -shift);

  float elevation = waveElevation(modelPosition.xyz) * uAudioFrequency;
  // elevation = pow(elevation, 2.0);
  // elevation += smoothstep(0.3, 1.0, uAudioFrequency);
  // modelPosition.x -= -sin(uAudioFrequency * 0.2);
  modelPosition.y += elevation;
  modelPositionAlpha.x += abs(1.0 + sin(uAudioFrequency + waveElevation(modelPositionAlpha)) * 2.0);
  modelPositionBeta.z += waveElevation(modelPositionBeta);

  // Compute Normal
  vec3 alphaNeighbor = normalize(modelPositionAlpha - modelPosition.xyz);
  vec3 betaNeighbor = normalize(modelPositionBeta - modelPosition.xyz);
  vec3 computeNormal = cross(alphaNeighbor, betaNeighbor);

  // modelPosition.x = uAudioFrequency;
  // modelPosition.y += fract(sin(elevation * aRandom) * uAudioFrequency);
  // modelPosition.x -= sin(aRandom * 0.01 * (uFrequency.x - uTimeAnimation * smoothstep(-0.144, 0.987, -uAudioFrequency * 0.002) * 0.001));
  // modelPosition.z += sin(-aRandom * 0.01 * (uFrequency.y - uTimeAnimation * smoothstep(-0.212, 1.188, uAudioFrequency * 0.05)) * 0.02) * 13.21;

// Audio levels used with perlin noise
  // float noise = 5.0 * perlinClassic3D(vec3(position.yx + uTime, vec3(10.0)));
  // float displacementInteger = (uAudioFrequency * 30.0) * (noise / 13.0);
  // float displacementFraction = fract(displacementInteger);

  // float generateNoise = fract(sin(noise) * 1.0);
  // generateNoise = perlinClassic3D(vec3(displacementInteger));
  // generateNoise = mix(perlinClassic3D(vec3(displacementInteger)), perlinClassic3D(vec3(displacementInteger + 1.0)), displacementFraction);
  // generateNoise = mix(perlinClassic3D(vec3(displacementInteger)), perlinClassic3D(vec3(displacementInteger + 1.0)), smoothstep(0.0, 1.0, displacementFraction));

  // displacementInteger = smoothstep(0.0, 1.0, displacementFraction);

  // Glitching effect
  // float glitchTime = uTimeAnimation - modelPosition.y * 0.02;
  // float stuttering = sin(glitchTime) + sin(glitchTime * 3.55) + sin(glitchTime * 8.89);
  // stuttering /= 3.0 * displacementInteger;
  // stuttering = smoothstep(0.3, 1.0, stuttering);
  // stuttering *= 0.21;
  // modelPosition.x += (random2D(modelPosition.xz * uAudioFrequency * uTime) - 0.5) * stuttering;
  // modelPosition.z += (random2D(modelPosition.zx * generateNoise * 0.8 * uTimeAnimation) - 0.5) * stuttering;

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