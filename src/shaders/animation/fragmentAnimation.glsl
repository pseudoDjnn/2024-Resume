#define PI 3.1415926535897932384626433832795
#define TAU  6.28318530718
#define NUM_OCTAVES 5

precision mediump float;

uniform vec2 uMouse;
uniform vec2 uResolution;

uniform float uAudioFrequency;
uniform float uFrequencyData[256];

uniform float uTime;

varying vec2 vUv;

#include ../includes/effects/fbm.glsl
#include ../includes/effects/rotation.glsl
#include ../includes/effects/palette.glsl
#include ../includes/effects/morphingShape.glsl
#include ../includes/shapes/gyroid.glsl
#include ../includes/shapes/octahedron.glsl

float sdf(vec3 position) {

  // float distorted = fractalBrownianMotion(position * 2.0, 1.0) / 5.0;

  // float intensity = uFrequencyData[int(distorted * 255.0)]

  // float intensity = uFrequencyData[int(mod(fract(distorted * cos(uTime + gl_FragCoord.z) * sin(uTime + gl_FragCoord.y)), 256.0))];

  // Various rotational speeds
  vec3 position1 = rotate(position, vec3(1.0), sin(-uTime * 0.1) * 0.3);

  position1.xz *= rot2d(uTime * 0.3 + PI - position.x * 0.8 + positionEase((sin(0.3) * fract(-0.3)), 0.5 - sin(uAudioFrequency * 0.01)));

  // position1.zy *= rot2d(position.x * 0.5 * cos(uTime * 0.5));

  vec3 position2 = rotate(position, vec3(0.5), sin(-uTime * 0.1) * 0.2);

  position2.xz *= rot2d(uTime * 0.3 - -position.x * 0.8 - positionEase((sin(uTime * 0.03) * fract(-0.3)), 0.8 - sin(uTime)));

  // position1.z += sin(position1.x * 5.0 + uAudioFrequency) * 0.1;
  // position1 += polynomialSMin(uAudioFrequency * 0.003, dot(sqrt(uAudioFrequency * 0.02), 0.3), 0.3);

  float octaGrowth = sin(uAudioFrequency * 0.005 + 0.5) / 1.0 + 0.1;
  // position1.y += sin(uTime) * (0.1 * octaGrowth);

  // vec3 position2 = rotate(position1 - shapesPosition * -0.5, vec3(1.0), uAudioFrequency * 0.001);

  // vec3 position3 = -rotate(position1, vec3(1.0), sin(uTime));
  // position3.xz *= rot2d(position.y * uTime);
  // position3.xz *= rot2d(position.y * uTime);

  // Copied position used to make the actual copyPosition 
  // vec3 position4 = rotate(position, sin(position1 + uTime * 0.3), 3.0);

// Copy of the vec3 position
  // vec3 copyPosition = position4;
  // vec3 copyPositionRotation = abs(sin(uAudioFrequency * PI * 2.0 * rotate(position, vec3(0.5), fract(uTime / 8.0) * cos(uAudioFrequency * 0.02))));
  // copyPosition.z += uTime * 0.5;
  // copyPosition.xy = sin(fract(copyPositionRotation.xy * uAudioFrequency) - 0.5);
  // copyPosition.z = mod(position.z, 0.21) - 0.144;

  // float squareWave = sin(abs(ceil(smoothstep(-0.3, 0.5, -uAudioFrequency * 0.3) + PI * (sin(uAudioFrequency + position.z) + (sin(uAudioFrequency * 0.1) - uTime * 0.2))) + floor(2.144 * 1.08) * 0.2));

// Shapes used

  float octahedron = sdOctahedron(position, octaGrowth);

  float ground = position.y + .55;
  position.z -= uTime;
  position *= 3.0;
  position.y += 1.0 - length(uTime + position.z) * 0.5 + 0.5;
  float groundWave = abs(dot(sin(position), cos(position.yzx))) * 0.1;
  ground += groundWave;

  return polynomialSMin(0.1, octahedron, 1.0);
}

// float ground(vec3 position) {
//   float ground = position.y + .55;
//   position.z -= uTime * 0.2;
//   position *= 3.0;
//   position.y += 1.0 - length(position.z) * 0.5 + 0.5;
//   float groundWave = abs(dot(sin(position), cos(position.yzx))) * 0.1;
//   return ground += groundWave;
// }

vec3 calcNormal(in vec3 position) {
  const float epsilon = 0.001;
  const vec2 normalPosition = vec2(epsilon, 0);
  return normalize(vec3(sdf(position + normalPosition.xyy) - sdf(position - normalPosition.xyy), sdf(position + normalPosition.yxy) - sdf(position - normalPosition.yxy), sdf(position + normalPosition.yyx) - sdf(position - normalPosition.yyx)));
}

// Helper function to calculate the ray direction
vec3 calculateRayDirection(vec2 uv, vec3 camPos) {
  vec2 centeredUV = (uv - vec2(0.5)) + vec2(0.5);
  return -normalize(vec3(centeredUV - vec2(0.5), 1.0));
}

// Function to compute the light and shadow effects
vec3 computeLighting(vec3 position, vec3 normal, vec3 camPos, vec3 lightDir) {
  float diff = dot(normal, lightDir) * 0.5 + 0.5;
  float fresnel = pow(0.3 - dot(normalize(position - camPos), normal), 3.0);
  return vec3(diff) * fresnel;
}

// Function to apply shadow and glow effects
vec3 applyShadowAndGlow(vec3 color, vec3 position, float centralLight, vec3 camPos) {

    // Apply a shape-changing transformation to camPos for the glow effect
  float timeFactor = uTime * 0.5;
  float audioFactor = uAudioFrequency * 0.2;

    // Introduce noise for more organic distortion
  float noiseFactor = smoothNoise(position * 0.5 + uTime * 0.3);
  float fbmNoise = fractalBrownianMotion(position * 0.8, 5.0) + uFrequencyData[128] * 0.3;

  // Distort camPos to create a dynamic, shape-changing effect and 
  // smoothly distort camPos for more natural, evolving glow
  vec3 distortedCamPos = camPos + vec3(sin(timeFactor - camPos.x * 2.5 - fbmNoise) * 0.13, cos(timeFactor + camPos.y * 1.8 - noiseFactor) * 0.21, sin(uAudioFrequency * camPos.z * 5.0 * noiseFactor) * 0.8);
  // vec3 distortedCamPos = camPos + vec3(smoothstep(0.1, 0.8, fbmNoise) * sin(timeFactor) * 0.2, smoothstep(0.2, 0.8, noiseFactor) * cos(timeFactor * 1.5) * 0.13, smoothstep(0.3, 0.8, fbmNoise) * sin(uTime) * 0.21);

    // Calculate glow using the distorted camPos
  float glow = organicGyroid(sin(uTime * 0.2 - distortedCamPos), sin(uTime - 0.2), 0.1, 0.8) * 0.2;
  // float glow = sdf(distortedCamPos);
  // float glow = sdOctahedron(distortedCamPos, 0.1);

    // Adjust light calculations to soften and tone down the brightness
  float light = 0.03 / (centralLight + 0.13 - fbmNoise);
  // vec3 lightColor = vec3(0.8, 0.8, 0.5) / palette(light - fbmNoise); // Softer, more muted colors
  vec3 lightColor = -mix(fract(uTime * 0.3 * vec3(0.8, 0.01, 0.5)), fract(uTime * 0.3 * vec3(0.2, 0.2, 0.2)), glow) - palette(light * glow * uFrequencyData[64]); // Muted yet dynamic light colors

// Enhanced dynamic light color using palette and audio-driven variations
  // vec3 lightColor = mix(palette(light * glow + uFrequencyData[64] * 0.5),        // Audio-influenced palette colors
  // palette(glow * fbmNoise + uFrequencyData[192] * 0.3),   // Palette blended with FBM and higher frequency
  // sin(uTime * 0.3) * 0.5 + 0.5                            // Time-driven oscillation for dynamic blending
  // );

    // Apply glow effect to the color, modulating by audio frequency
  // color += sin(uAudioFrequency * 0.3 * cos(0.5 - centralLight)) * smoothstep(-0.3, 0.03, glow) * lightColor - 1.0 - sin(uAudioFrequency) + 0.5 * 0.5;

   // Apply the glow effect to the color with more organic modulation using frequency and noise
  // color += smoothstep(-0.13, 0.05, glow) * lightColor * sin(uAudioFrequency * 0.34 * cos(0.5 - centralLight + fbmNoise)) * 1.8;
  // Calculate the distance from the raymarch origin (simulating fisheye lens distortion)
  // float distFromOrigin = length(position - camPos);
  float distFromOrigin = abs(position.x - camPos.x) * 0.8 + abs(position.y - camPos.y) * 0.2 + abs(position.z - camPos.z) * 0.5;

// Darken color closer to the start of the raymarch
  // float vignette = smoothstep(0.8, 1.0, distFromOrigin * 0.3); // Increase this value to tighten the effect
  float vignette = smoothstep(0.5, 1.0, distFromOrigin * 0.5 + position.x * 0.1);

// Modify color based on distance, with black near the edges and brighter toward the center
// #ifdef ENABLE_FISHEYE
  color += vignette * smoothstep(-0.13, 0.05, glow) * lightColor * 0.5 * fract(uAudioFrequency * 0.34 * floor(1.0 - centralLight + fbmNoise)) * 1.5;
  // #endif
  // color += vignette * smoothstep(-0.1, 0.05, glow) * lightColor - (0.8 + sin(position.y * 1.2 + fbmNoise) * 0.3);

  // Additional subtle frequency-based modulation for organic blending
  color -= 0.5 * sin(uFrequencyData[255] + fbmNoise * 0.3) + 0.5;

  // Final smooth transition for more of a natural feel and color effect
  color = smoothstep(-0.3, 1.0, color);

  return color;
}

// Main raymarching loop
vec3 raymarch(vec3 raypos, vec3 ray, float endDist, out float startDist) {

  vec3 color = palette(endDist);

  for (int i = 0; i < 100; i++) {

    vec3 position = raypos + startDist * ray;
    // position.xy *= rot2d(startDist * 0.2 * uMouse.x);
    // position.y = max(-0.9, position.y);
    // position.y += sin(startDist * (uMouse.y - 0.5) * 0.02) * 0.21;

    float distanceToSurface = sdf(position);

    startDist += distanceToSurface;

    if (abs(distanceToSurface) < 0.0001 || startDist > endDist) {
      break;
    }

    // float alpha = cos(uTime - tan(position.x * 8.0) * fract(uAudioFrequency) * 3.0) * 1.0 / 2.0;
    // float beta = sin(mod(position.y * 89.0, uTime) - uTime * 2.0) * 1.0 / 2.5;
    // float charlie = sin(uTime * 2.0 + 1.0 - fract(position.x) * 8.0 + 1.0 - fract(position.y) * 2.0) * 0.5 + 0.5;
    // float delta = uTime + (fractalBrownianMotion(position, alpha - (beta / 3.0) - charlie * 0.3) * 0.2) * 0.3;

    // float harmonic = sin(uTime * 0.5 + TAU * 3.0) * uFrequencyData[128];
    // color *= harmonic - palette(cos(uTime * 3.0 + sin(startDist + harmonic) + 0.5) * uFrequencyData[255]) + 1.0 / 3.0;

    // color *= sin(uTime + TAU * 1.5) - palette(delta - sin(uTime * round(endDist) + abs(ceil(uAudioFrequency * 0.008 * PI * tan(startDist))) * floor(2.0 + 1.0)) * uFrequencyData[255]) + 1.0 / 2.0;
    float fbmVal = fractalBrownianMotion(position + 0.5, 5.0) - sin(uTime);

    float alpha = 1.0 - exp(-0.05 * startDist);

    float gradient = smoothstep(0.0, 1.0, position.y * 0.1 + fbmVal);

    float turb = fbmVal * (1.0 + uFrequencyData[34] * 0.1);

    color = mix(color, vec3(0.2, 0.5, 0.8), gradient); // Smooth gradient coloring
    color += vec3(turb) * 0.05;                         // Turbulence-based variations
    color = mix(color, vec3(0.0), alpha);        // Fade with distance

    // color = smoothstep(-1.0, 1.0, color) * 0.5 + 0.5;

  }
  return color;
}

// Main function
void main() {
    // Background color based on distance from center
  // float dist = length(vUv - vec2(0.5));
  // vec3 background = cos(mix(vec3(0.0), vec3(0.3), dist));

    // Camera and ray setup
  vec3 camPos = vec3(0.0, -0.1 * sin(uTime), 5.8 - (smoothstep(0.0, 0.5, fract(uAudioFrequency * 0.01)) * sin(uAudioFrequency * 0.008)));
  vec3 ray = calculateRayDirection(1.0 - vUv, camPos);

    // Raymarching
  float startDist = 0.0;
  float endDist = 5.8;
  vec3 color = raymarch(camPos, ray, endDist, startDist);

    // Lighting and shading
  if (startDist < endDist) {
    vec3 position = camPos + startDist * ray;
    vec3 normal = calcNormal(position);
    vec3 lightDir = -normalize(position);

      // Calculate center distance for lighting
    float centerDist = length(position);
    // float centralLight = dot(vUv - 1.0, vUv) * (camPos.z - 1.0);
    float centralLight = sdf(camPos);
    // centerDist = uTime * centralLight;

    // Interaction with uFrequencyData
  //   float frequencyIndex = mod(centerDist * 50.0 + uTime * 10.0, 256.0); // Adjust the scaling and offset for the effect
  //   float frequencyValue = uFrequencyData[int(frequencyIndex)];

  // // Apply the frequency data to modify the color
  //   vec3 frequencyColor = vec3(frequencyValue / 256.0) * vec3(0.5, 0.8, 1.0); // Base color influenced by frequency
  //   color = mix(color, frequencyColor, smoothstep(0.0, 1.0, frequencyValue * centralLight));

    // Compute lighting and shadow effects
    color = computeLighting(position, normal, camPos, lightDir);
    color = applyShadowAndGlow(color, position, centralLight, camPos);
    color *= (1.0 - vec3(startDist / endDist / centerDist));

    // Edge fading
    // color *= smoothstep(-0.8, 0.5, vUv.x);
    // color *= smoothstep(-1.0, 0.3, vUv.x);
    // color *= smoothstep(-0.8, 0.5, vUv.y);
    // color *= smoothstep(-1.0, 0.3, vUv.y);
  }

    // Final color output
  gl_FragColor = vec4(color, 1.0);
    #include <tonemapping_fragment>
    #include <colorspace_fragment>
}