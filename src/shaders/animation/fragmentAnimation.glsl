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

vec3 palette(float tone) {

  vec3 a = vec3(0.149, 0.141, 0.912);
  vec3 b = vec3(1.000, 0.833, 0.224);
  vec3 c = vec3(0.3, 0.3, 0.8);
  vec3 d = vec3(0.263, 0.416, 0.557);

  return a + b * cos(sin(uTime + c) * tone + d) * uAudioFrequency;
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
  float stripes = mod((vPosition.y - uTime * 0.03) * 21.0, 1.0);
  stripes = pow(stripes, 3.0);

  // Fresnel
  float fresnel = dot(viewDirection, normal) + 1.0;
  fresnel = pow(fresnel, 2.0);

  // Falloff
  float falloff = smoothstep(0.8, 0.0, fresnel);

  // Holographic
  float holographic = stripes * fresnel;
  holographic += fresnel * 0.89;
  holographic *= falloff;

  // Color mixing
  // vec3 blackColor = vec3(0.0);
  // vec3 uvColor = vec3(vUv, strength);
  // vec3 mixedColor = mix(blackColor, uvColor, color);

  // Color Remap
  color = smoothstep(0.03, 0.8, color);

  // Smoother edges
  color *= smoothstep(0.1, 0.8, vUv.x);
  color *= smoothstep(0.5, 1.0, vUv.x);
  color *= smoothstep(0.1, 0.8, vUv.y);
  color *= smoothstep(0.5, 1.0, vUv.y);

  // Lights
  // vec3 light = vec3(0.0);

  // light += ambientLight(vec3(1.0), 1.0);
  // light += directionalLight(vec3(1.0, 0.0, 0.5), 1.0, normal, vec3(0.0, 0.25, 0.0), viewDirection, 1.0);

  // color *= light;

  // color = mixedColor;
  // mixedColor = color;

  // Halftone
  color = halftone(color, uShadowRepetitions, vec3(0.0, -1.0, 0.0), -0.8, 1.5, uShadowColor, normal);
  color = halftone(color, uLightRepetitions, vec3(1.0, 1.0, 0.0), 0.5, 1.5, uLightColor, normal);

  // color = mix(color, pointColor, color);

  // vec2 uv = gl_PointCoord;
  // float distanceToCenter = length(uv - vec2(0.5));

  // if (distanceToCenter > 0.5)
  //   discard;

  vec2 uv = vUv;
  vec2 uv0 = uv;
  vec3 finalColor = vec3(0.0);

  float minimumDistance = 100.0;

  for (float i = 0.0; i < 3.0; i++) {
    uv = mod(uv * 1.5, uAudioFrequency) - 0.5 + stripes;
    float distanceToCenter = length(uv) * exp(-length(uv0));

    vec3 colorLoop = palette(length(uv0) + i * 0.5 + uTime * 34.5);

    minimumDistance = min(minimumDistance, distanceToCenter);

    distanceToCenter = 1.0 + sin(distanceToCenter * 8.3 * uTime) / 8.5;
    distanceToCenter = abs(distanceToCenter);

    distanceToCenter = pow(0.2 / distanceToCenter, 1.2);

    // distanceToCenter = smoothstep(0.2, 0.5, distanceToCenter);

    finalColor += colorLoop * distanceToCenter;
  }

  color *= finalColor;
  // color -= step(0.8, abs(sin(55.0 * minimumDistance))) * 0.3;
  // finalColor = smoothstep(0.3, 0.8, finalColor);
  // fragColor = vec4(finalColor, 1.0);

  // Final color
  gl_FragColor = vec4(finalColor, holographic);
    #include <tonemapping_fragment>
    #include <colorspace_fragment>
}