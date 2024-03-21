uniform vec2 uResolution;
uniform vec3 uColor;
uniform vec3 uDepthColor;
uniform vec3 uSurfaceColor;
uniform float uColorOffset;
uniform float uColorMultiplier;
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
  float stripes = mod((vPosition.y - uTime * 0.08) * 233.0, 1.0);
  stripes = pow(stripes, 2.0);

  // Fresnel
  float fresnel = dot(viewDirection, normal) + 1.0;
  fresnel = pow(fresnel, 2.0);

  // Falloff
  float falloff = smoothstep(0.5, 0.2, fresnel);

  // Holographic
  float holographic = stripes * fresnel;
  holographic += fresnel * 1.21;
  holographic *= falloff;

  // Color mixing
  // vec3 blackColor = vec3(0.0);
  // vec3 uvColor = vec3(vUv, strength);
  // vec3 mixedColor = mix(blackColor, uvColor, color);

  // Color Remap
  color = smoothstep(-0.13, 0.8, color);

  // Smoother edges
  color *= smoothstep(0.1, 0.3, vUv.x);
  color *= smoothstep(0.5, 1.0, vUv.x);
  color *= smoothstep(0.1, 0.3, vUv.y);
  color *= smoothstep(0.5, 1.0, vUv.y);

  // Lights
  vec3 light = vec3(0.0);

  light += ambientLight(vec3(1.0), 1.0);
  light += directionalLight(vec3(0.0, 0.0, 1.0), 1.0, normal, vec3(1.0, 0.0, 1.0), viewDirection, 1.0);

  color *= light;

  // color = mixedColor;
  // mixedColor = color;

  // Halftone
  color = halftone(color, 144.0, vec3(0.0, -1.0, 0.0), -0.8, 1.5, vec3(0.0, 0.3, 0.3), normal);
  color = halftone(color, 55.0, vec3(1.0, 0.0, 1.0), 0.8, 1.8, vec3(0.5, 0.3, 0.2), normal);

  color = mix(color, light, color);

  // vec2 uv = gl_PointCoord;
  // float distanceToCenter = length(uv - vec2(0.5));

  // if (distanceToCenter > 0.5)
  //   discard;

  // Final color
  gl_FragColor = vec4(color, holographic / 5.0);
    #include <tonemapping_fragment>
    #include <colorspace_fragment>
}