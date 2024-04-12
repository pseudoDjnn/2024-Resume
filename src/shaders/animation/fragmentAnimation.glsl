#define PI 3.1415926535897932384626433832795

uniform vec2 uResolution;
uniform vec3 uColor;
uniform vec3 uLightColor;
uniform vec3 uShadowColor;
// uniform vec3 uDepthColor;
// uniform vec3 uSurfaceColor;
uniform float uAudioFrequency;
uniform float uColorOffset;
uniform float uColorMultiplier;
uniform float uLightRepetitions;
uniform float uShadowRepetitions;
uniform float uTime;

// varying vec3 vColor;
varying float vElevation;
varying float vRandom;
varying vec3 vNormal;
varying vec3 vPosition;
varying vec2 vUv;

#include ../includes/effects/random2D.glsl
#include ../includes/lights/ambientLight.glsl
#include ../includes/lights/directionalLight.glsl
#include ../includes/effects/halftone.glsl

float parabola(float x, float k) {
  return pow(4.0 * x * (1.0 - x), k);
}

float quinticPolynomial(float x) {
  return x * x * x * (x * (x * 6.0 - 15.0) + 1.0);
}

vec3 palette(float tone) {

  vec3 a = cos(uAudioFrequency * 0.02 * vec3(0.5, 0.5, 0.5));
  vec3 b = atan(uTime * uTime * vec3(0.5, 0.5, 0.5));
  vec3 c = cos(uTime * vec3(1.0, 1.0, 1.0));
  vec3 d = sin(uAudioFrequency * 0.02 * uTime * vec3(0.263, 0.416, 0.557));

  return a + b * cos(sin(c) * tone + d) * pow(uAudioFrequency, 1.0);
}

void main() {

  // Base color
  vec3 viewDirection = normalize(vPosition - cameraPosition);
  // float mixedStrength = (vElevation + uColorOffset) * uColorMultiplier;
  // mixedStrength = smoothstep(0.0, 1.0, mixedStrength);
  // vec3 color = mix(uDepthColor, uSurfaceColor, mixedStrength);

  // Normal
  vec3 normal = normalize(vNormal);
  if (!gl_FrontFacing)
    normal *= -1.0;

  vec3 color = uColor;

  // Randoms
  // float strength = random2D(vUv * vRandom * 89.0);

  // Strips
  float stripes = mod((vPosition.y - uAudioFrequency) * 21.0, 1.0);
  stripes = pow(stripes, 3.0);

  // Fresnel
  float fresnel = dot(viewDirection, normal) + 1.0;
  fresnel = pow(fresnel, 2.0);

  // Falloff
  float falloff = smoothstep(0.8, 0.0, fresnel);

  // Holographic
  float holographic = stripes * fresnel;
  holographic += fresnel * 1.21;
  holographic *= falloff;
  // holographic *= palette(holographic);

  // Color mixing
  // vec3 blackColor = vec3(0.0);
  // vec3 uvColor = vec3(vUv, strength);
  // vec3 mixedColor = mix(blackColor, uvColor, color);

  // Color Remap
  // color = smoothstep(0.3, 0.8, color * uAudioFrequency);
  color *= parabola(uTime * holographic * uAudioFrequency, 1.0);

  // Smoother edges
  color *= smoothstep(0.8, 0.0, vUv.x);
  color *= smoothstep(-1.0, 0.1, vUv.x);
  color *= smoothstep(0.8, 0.0, vUv.y);
  color *= smoothstep(-1.0, 0., vUv.y);

  // Lights
  // vec3 light = vec3(0.0);

  // light += ambientLight(vec3(1.0), 1.0);
  // light += directionalLight(vec3(1.0, 0.0, 0.5), 1.0, normal, vec3(0.0, 0.25, 0.0), viewDirection, 1.0);

  // color *= light;

  // color = mixedColor;
  // mixedColor = color;

  // Halftone
  // color = halftone(color, uShadowRepetitions, vec3(0.0, -1.0, 0.0), -0.8, 1.5, uShadowColor, normal);
  // color = halftone(color, uLightRepetitions, vec3(1.0, 1.0, 0.0), 0.5, 1.5, uLightColor, normal);

  // color = mix(color, pointColor, color);

  // vec2 uv = gl_PointCoord;
  // float distanceToCenter = length(uv - vec2(0.5));

  // if (distanceToCenter > 0.5)
  //   discard; 

  vec2 uv = vUv;
  vec2 uv0 = uv;
  vec3 finalColor = vec3(0.0);

  float minimumDistance = 1.0;

  for (float i = 0.0; i < 4.0; i++) {
    uv = fract(uv * 1.5) - 0.5;

    float distanceToCenter = length(uv) * exp(-length(uv0));

    vec3 colorLoop = palette(length(uv0) + i * 0.5 * distance(uAudioFrequency, minimumDistance));

    minimumDistance = min(minimumDistance, distanceToCenter);

    distanceToCenter = sin(distanceToCenter * 8.0 + step(uAudioFrequency * 0.2, minimumDistance)) / 8.0;
    distanceToCenter = abs(distanceToCenter);

    distanceToCenter = quinticPolynomial(0.01 / distanceToCenter);

    // distanceToCenter = smoothstep(0.2, 0.5, distanceToCenter);

    finalColor += colorLoop * distanceToCenter;
  }

  // color *= finalColor;
  // finalColor -= step(0.8, abs(sin(55.0 * minimumDistance))) * 0.3;
  // finalColor = smoothstep(0.3, 0.8, finalColor);
  // fragColor = vec4(finalColor, 1.0);

  // Final color
  gl_FragColor = vec4(finalColor, holographic);
    #include <tonemapping_fragment>
    #include <colorspace_fragment>
}