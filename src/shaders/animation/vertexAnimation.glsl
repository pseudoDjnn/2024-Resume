#define PI 3.1415926535897932384626433832795

// uniform vec2 uFrequency;
// uniform vec2 uResolution;
// uniform vec2 uWaveFrequency;

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

// #include ../includes/effects/perlin.glsl
#include ../includes/effects/random2D.glsl
#include ../includes/effects/terrainGeneration.glsl
#include ../includes/effects/boxFrame.glsl

float quarticPolynomial(float x) {
  return x * x * (2.0 - x * x);
}

float quadraticRational(float x) {
  return x * x / (2.0 * x * x - uAudioFrequency * 0.05 * x + 1.0);
}

float trigonmetric(float x) {
  return 0.5 - 0.5 * cos(PI * x);
}

// quadratic polynomial
float quadraticPolynomial(float a, float b, float k) {
  k *= 4.0;
  float h = max(k - abs(a - b), 0.0) / k;
  return min(a, b) - h * h * k * (1.0 / 4.0);
}

void main() {
  // Base Postion
  float shift = 0.01;
  vec4 modelPosition = modelMatrix * vec4(position, 1.0);
  vec3 modelPositionAlpha = modelPosition.xyz + vec3(shift, 0.0, 0.0);
  vec3 modelPositionBeta = modelPosition.xyz + vec3(0.0, 0.0, -shift);

  float elevation = terrainGeneration(modelPosition.xyz, 0.0);
  vec3 frame = calcNormal(vec3(elevation));
  // elevation = pow(elevation, 2.0);
  // elevation += smoothstep(0.3, 1.0, uAudioFrequency);
  // modelPosition.x += sin(abs(uTimeAnimation * ceil(floor(PI * fract(uAudioFrequency * 0.02)) * 2.0 + 1.0)));
  // modelPosition.z = frame / 1.0;

  // modelPosition.z += quadraticPolynomial(uTime, 1.0, -uTime);
  modelPosition.yx += quadraticRational(elevation) * 0.001;
  // modelPosition.z += trigonmetric(elevation) * 0.2;

  // modelPosition.x -= sin(uAudioFrequency * 0.02 * ceil(floor(PI * fract(elevation * 0.0002)) * 2.0 + 1.0));
  // modelPosition.x += cos(uTime * -uAudioFrequency * 0.002 + fract(elevation * 0.0002)) * 2.0 + 1.0;
  // modelPosition.x -= 1.0 + atan(uAudioFrequency * 0.1 + uTime, 1.0) + elevation;
  // modelPosition.xy += sin(uTime * 2.0 * sinc(uAudioFrequency * 0.02, -1.0) + elevation + PI);
  // modelPosition.y += sin(uAudioFrequency * 0.02 + elevation * 0.2);
  // modelPosition.xy -= cubicRational(uAudioFrequency * 0.1 * elevation);
  // modelPosition.xy += cubicRational(uAudioFrequency * 0.1 * elevation);
  // modelPosition.z += 1.0 * polynomialImpluse(uAudioFrequency * 0.02 + exp(uTime * uTime * elevation), 1.0);

  modelPositionAlpha.y += terrainGeneration(modelPositionAlpha, 1.0);
  modelPositionBeta.y += terrainGeneration(modelPositionBeta, 1.0);

  // Compute Normal
  vec3 alphaNeighbor = normalize(modelPositionAlpha - modelPosition.xyz);
  vec3 betaNeighbor = normalize(modelPositionBeta - modelPosition.xyz);

  // float boxFrame = sdBoxFrame(alphaNeighbor, betaNeighbor, elevation);

  // float boxFrame = sdRoundBox(alphaNeighbor, betaNeighbor, 1.0);
  // modelPosition.z += boxFrame;
  vec3 computeNormal = cross(alphaNeighbor, betaNeighbor);
  // computeNormal *= frame;
  // modelPosition += map(vec3(computeNormal * 0.2));

  // computeNormal = smoothstep(0.8, 0.0, computeNormal);

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
  float glitchTime = uAudioFrequency * 0.2 - modelPosition.y * 0.2;
  float stuttering = sin(glitchTime) + sin(glitchTime * 3.55) + sin(glitchTime * 8.89);
  stuttering /= 3.0;
  // stuttering = smoothstep(0.3, 1.0, stuttering);
  // stuttering = polynomialImpluse(stuttering, 1.0);
  // stuttering = rational(stuttering, 1.0);
  stuttering *= uAudioFrequency * 0.1;
  stuttering *= 0.21;
  modelPosition.x += (random2D(modelPosition.xz * uAudioFrequency) - 0.5) * stuttering;
  modelPosition.z += (random2D(modelPosition.zx * uAudioFrequency) - 0.5) * stuttering;

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