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
// #include ../includes/effects/random2D.glsl
#include ../includes/effects/terrainGeneration.glsl
// #include ../includes/effects/boxFrame.glsl

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

float pcurve(float x, float a, float b) {
  float k = pow(a + b, a + b) / (pow(a, a) * pow(b, b));
  return k * pow(x, a) * pow(1.0 - x, b);
}

float cubicPulse(float c, float w, float x) {
  x = abs(x - c);
  if (x > w)
    return 0.0;
  x /= w;
  return 1.0 - x * x * (3.0 - 2.0 * x);
}

float expStep(float x, float n) {
  return exp2(-exp2(n) * pow(x, n));
}

mat2 rotate(float axis) {
  return mat2(cos(axis), -sin(axis), sin(axis), cos(axis));
}

float smin(float a, float b, float k) {
  k *= 1.0 / (1.0 - sqrt(0.5));
  return max(k, min(a, b)) -
    length(max(k - vec2(a, b), 0.0));
}

float sdBoxFrame(vec3 p, vec3 b, float e) {
  p = abs(p) - b;
  vec3 q = abs(p + e) - e;
  return min(min(length(max(vec3(p.x, q.y, q.z), 0.0)) + min(max(p.x, max(q.y, q.z)), 0.0), length(max(vec3(q.x, p.y, q.z), 0.0)) + min(max(q.x, max(p.y, q.z)), 0.0)), length(max(vec3(q.x, q.y, p.z), 0.0)) + min(max(q.x, max(q.y, p.z)), 0.0));
}

float doubleCubicSeat(float x, float a, float b) {

  float epsilon = 0.00001;
  float min_param_a = 0.0 + epsilon;
  float max_param_a = 1.0 - epsilon;
  float min_param_b = 0.0;
  float max_param_b = 1.0;
  a = min(max_param_a, max(min_param_a, a));
  b = min(max_param_b, max(min_param_b, b));

  float y = 0.0;
  if (x <= a) {
    y = b - b * pow(1.0 - x / a, 3.0);
  } else {
    y = b + (1.0 - b) * pow((x - a) / (1.0 - a), 3.0);
  }
  return y;
}

void main() {
  // Base Postion
  float shift = 0.01;
  vec4 modelPosition = modelMatrix * vec4(position, 1.0);
  vec3 modelPositionAlpha = modelPosition.xyz + vec3(shift, 0.0, 0.0);
  vec3 modelPositionBeta = modelPosition.xyz + vec3(0.0, 0.0, -shift);

  float elevation = terrainGeneration(modelPosition.zzz);
  float time = 0.02 * (uTime * 144.0);
  float box = sin(smoothstep(0.0, 0.1, uAudioFrequency * 0.02) + sdBoxFrame(vNormal, abs(modelPositionAlpha + modelPositionBeta), 8.0));
  modelPosition.z += atan(doubleCubicSeat(elevation, 0.0, 0.01));
  // modelPosition.y += sin(doubleCubicSeat(elevation, 0.0, 0.01));

  // elevation += smin(uAudioFrequency, 0.0, 1.0);
  // vPosition.y *= elevation;
  // modelPosition.xyz -= box;
  modelPosition.y += elevation;
  // vec3 frame = calcNormal(modelPositionAlpha * modelPositionBeta);

  float amplitude = 3.0;
  float frequency = 1.0;

  modelPosition.y += -sin(elevation * frequency + uAudioFrequency * 0.2);
  // modelPosition.z *= random2D(clamp(elevation * frequency, modelPosition.x, modelPosition.z) * modelPosition.xz);

  modelPosition.z += sin(-uAudioFrequency * 0.2 + sin(uAudioFrequency + box) + box);
  // modelPosition.xyz += cos(fract(length(elevation)) * frequency * 2.1 - length(smoothstep(0.0, 0.1, -uAudioFrequency))) * 5.5;

  // modelPosition.xy *= rotate(-uAudioFrequency - time * -0.01 * uAudioFrequency - time * 0.01);
  // modelPosition.x += cos(elevation * 3.0);
  // modelPosition.x += abs(cos(elevation * 2.5)) * 0.5 + 0.3;
  // modelPosition.x += abs(cos(elevation * 13.0) * sin(elevation * 3.0) * 0.8 + 0.1);
  // modelPosition.x += smoothstep(-0.5, 1.0, cos(elevation * 13.0)) * 0.2 + 0.5;
  // modelPosition.x -= sin(uAudioFrequency - -sin(time + elevation * frequency));
  // modelPosition.z *= -cos(elevation * frequency * 1.89 + time + uAudioFrequency * 1.89) * 2.0;
  // modelPosition.x *= expStep(elevation * frequency * 2.233 + time * 0.610, elevation) * 5.0;
  // modelPosition.z *= -sin(elevation * frequency * 5.1597 + time * 3.233) * 2.5;
  // modelPosition.xy += sin(abs(uAudioFrequency * 0.1 * ceil(floor(PI * fract(amplitude * 0.005)) * 2.0 + 1.0)));

  // elevation = pow(elevation, 2.0);
  // elevation += smoothstep(0.3, 1.0, uAudioFrequency);
  // modelPosition.x += sin(abs(uTimeAnimation * ceil(floor(PI * fract(uAudioFrequency * 0.02)) * 2.0 + 1.0)));

  // modelPosition.z += quadraticPolynomial(uTime, 1.0, -uTime);
  modelPosition.yx += quadraticRational(elevation * modelPosition.x * modelPosition.y) * 0.01;
  // modelPosition.z += trigonmetric(elevation) * 0.2;

  // modelPosition.x -= sin(uAudioFrequency * 0.02 * ceil(floor(PI * fract(elevation * 0.0002)) * 2.0 + 1.0));
  // modelPosition.x += cos(uTime * -uAudioFrequency * 0.002 + fract(elevation * 0.0002)) * 2.0 + 1.0;
  // modelPosition.x -= 1.0 + atan(uAudioFrequency * 0.1 + uTime, 1.0) + elevation;
  // modelPosition.xy += sin(uTime * 2.0 * sin(uAudioFrequency * 0.02) + elevation + PI);
  // modelPosition.y += sin(uAudioFrequency * 0.02 + elevation * 0.2);
  // modelPosition.xy -= cubicRational(uAudioFrequency * 0.1 * elevation);
  // modelPosition.xy += cubicRational(uAudioFrequency * 0.1 * elevation);
  // modelPosition.z += quarticPolynomial(uAudioFrequency * 0.02 + exp(uTime * uTime * elevation));

  // modelPositionAlpha.y += terrainGeneration(modelPositionAlpha, 0.0);
  // modelPositionBeta *= frame;
  // modelPositionBeta.z += terrainGeneration(modelPositionBeta, 1.0);

  // Compute Normal
  vec3 alphaNeighbor = normalize(modelPositionAlpha - modelPosition.xyz);
  // alphaNeighbor += frame;
  vec3 betaNeighbor = normalize(modelPositionBeta - modelPosition.xyz);
  // betaNeighbor += frame;
  // modelPosition *= sdBoxFrame(alphaNeighbor, betaNeighbor, elevation);

  // float boxFrame = sdBoxFrame(alphaNeighbor, betaNeighbor, elevation);

  // float boxFrame = sdRoundBox(alphaNeighbor, betaNeighbor, 1.0);
  // modelPosition.z += boxFrame;
  vec3 computeNormal = cross(alphaNeighbor, betaNeighbor);
  // computeNormal *= box;
  // computeNormal *= calcNormal(computeNormal);
  // modelPosition += map(computeNormal);
  // computeNormal += frame;
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
  // float glitchTime = uAudioFrequency * 0.2 - modelPosition.y * 0.2;
  // float stuttering = sin(glitchTime) + sin(glitchTime * 3.55) + sin(glitchTime * 8.89);
  // stuttering /= 3.0;
  // // stuttering = smoothstep(0.3, 1.0, stuttering);
  // // stuttering = polynomialImpluse(stuttering, 1.0);
  // // stuttering = rational(stuttering, 1.0);
  // stuttering *= uAudioFrequency * 0.1;
  // stuttering *= 0.21;
  // modelPosition.x += (random2D(modelPosition.xz * uAudioFrequency) - 0.5) * stuttering;
  // modelPosition.z += (random2D(modelPosition.zx * uAudioFrequency) - 0.5) * stuttering;

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