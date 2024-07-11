// #define PI 3.1415926535897932384626433832795

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

void main() {
  // Base Postion
  float shift = 0.01;
  vec4 modelPosition = modelMatrix * vec4(position, 1.0);
  vec3 modelPositionAlpha = modelPosition.xyz + vec3(shift, 0.0, 0.0);
  vec3 modelPositionBeta = modelPosition.xyz + vec3(0.0, 0.0, -shift);

  // float elevation = terrainGeneration(modelPosition.zzz);
  // float amplitude = 3.0;
  // float frequency = 1.0;
  // float audio = 0.2 * (uAudioFrequency * 144.0);
  // float time = 0.02 * (uTime * 144.0);
  // float box = sin(sdBoxFrame(vPosition, abs(modelPositionAlpha + modelPositionBeta), frequency));
  // modelPosition.xy *= rotate(-uAudioFrequency * 0.001 + uAudioFrequency * 0.001);
  // modelPosition.y += -sin(min(lerp(elevation) * frequency, clamp(elevation, 0.0, 0.1)));

  // box = lerp(log(elevation));
  // box *= smoothMin(1.0, 1.0, lerp(box));
  // modelPosition.z *= min(max(doubleCubicSeat(elevation, 0.0, 0.01), box), box);
  // 
  // 
  // modelPosition.z *= smoothMax(lerp(log(elevation * 0.03)), box, frequency);
  // 
  // modelPosition.z = exp(-modelPosition.y);
  // 
  // 
  // modelPosition.y += sin(doubleCubicSeat(elevation, 0.0, 0.01));

  // elevation += smin(uAudioFrequency, 0.0, 1.0);
  // vPosition.y *= elevation;
  // modelPosition.xyz += min(elevation, box);
  // modelPosition.y *= elevation;
  // vec3 frame = calcNormal(modelPositionAlpha * modelPositionBeta);

  // modelPosition.z *= random2D(clamp(elevation * frequency, modelPosition.x, modelPosition.z) * modelPosition.xz);

  // modelPosition.z -= length(-uAudioFrequency * 0.02 + atan(audio + box) * box);
  // modelPosition.xyz += cos(fract(length(elevation)) * frequency * 2.1 - length(smoothstep(0.0, 0.1, -uAudioFrequency))) * 5.5;

  // modelPosition.x += cos(elevation * 3.0);
  // modelPosition.x += abs(cos(elevation * 2.5)) * 0.5 + 0.3;
  // modelPosition.x += abs(cos(elevation * 13.0) * sin(elevation * 3.0) * 0.8 + 0.1);
  // modelPosition.x += smoothstep(-0.5, 1.0, cos(elevation * 13.0)) * 0.2 + 0.5;

  // modelPosition.y += sin(-sin(time + elevation * frequency));
  // modelPosition.x -= -cos(elevation * frequency * 1.89 + time * 0.2) * 2.5;
  // modelPosition.x += expStep(elevation * frequency * 2.233 + time * 0.610, box) * 1.5;
  // modelPosition.x += -sin(elevation * frequency * 5.1597 + time * 3.233) * 2.5;
  // modelPosition.x += sin(abs(uAudioFrequency * 0.1 * ceil(floor(PI * fract(amplitude * 0.005)) * 2.0 + 1.0)));

  // elevation = pow(elevation, 2.0);
  // elevation += smoothstep(0.3, 1.0, uAudioFrequency);
  // modelPosition.x += sin(abs(uTimeAnimation * ceil(floor(PI * fract(uAudioFrequency * 0.02)) * 2.0 + 1.0)));

  // modelPosition.z += quadraticPolynomial(uTime, 1.0, -uTime);
  // 
  // modelPosition.yx += quadraticRational(elevation * modelPosition.x * modelPosition.y) * 0.01;
  // 
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
  // 
  vec3 alphaNeighbor = normalize(modelPositionAlpha - modelPosition.xyz);
  vec3 betaNeighbor = normalize(modelPositionBeta - modelPosition.xyz);
  // 
  // modelPosition *= sdBoxFrame(alphaNeighbor, betaNeighbor, elevation);
  // float sdfBox = sdBoxFrame(alphaNeighbor, modelPositionAlpha, elevation);

  // float boxFrame = sdBoxFrame(alphaNeighbor, betaNeighbor, elevation);

  // float boxFrame = sdRoundBox(alphaNeighbor, betaNeighbor, 1.0);
  // modelPosition.z += boxFrame;
  // 
  vec3 computeNormal = cross(alphaNeighbor, betaNeighbor);
  // 
  // computeNormal *= min(alphaNeighbor, sdfBox);
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

  // Point size
  // gl_PointSize = 0.13 * uResolution.y;
  // gl_PointSize *= (1.0 / -viewPosition.z);

  // Varyings
  // vRandom = aRandom;
  // vElevation = elevation;
  vNormal = computeNormal;
  // vPosition = modelPosition.xyz;
  vUv = uv;
  // vUv = gl_Position.xy * 0.5 + 0.5;
}