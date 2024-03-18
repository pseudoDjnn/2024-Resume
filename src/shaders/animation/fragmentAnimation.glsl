uniform vec3 uColor;
uniform vec3 uDepthColor;
uniform vec3 uSurfaceColor;
uniform float uColorOffset;
uniform float uColorMultiplier;
uniform float uTime;

varying float vRandom;
varying float vElevation;
varying vec2 vUv;
varying vec3 vPosition;
varying vec3 vNormal;

#include ../includes/random2D.glsl

void main() {

  float mixedColors = (vElevation + uColorOffset) * uColorMultiplier;

  vec3 color = mix(uDepthColor, uSurfaceColor, mixedColors);

  float strength = random2D(vUv * vRandom * 20.0);

  // Normal
  vec3 normal = normalize(vNormal);
  if (!gl_FrontFacing)
    normal *= -1.0;

  // Strips
  float stripes = mod((vPosition.y - uTime * 0.02) * 21.0, 1.0);
  stripes = pow(stripes, 3.0);

  // Fresnel
  vec3 viewDirection = normalize(vPosition - cameraPosition);
  float fresnel = dot(viewDirection, normal) + 1.0;
  fresnel = pow(fresnel, 21.0);

  // Falloff
  float falloff = smoothstep(0.8, 0.0, fresnel);

   // Holographic
  float holographic = stripes * fresnel;
  holographic += fresnel * 1.21;
  holographic *= falloff;

  vec3 blackColor = vec3(0.0);
  vec3 uvColor = vec3(vUv, strength);
  vec3 mixedColor = mix(blackColor, uvColor, color);

  // Color Remap
  color = smoothstep(0.8, 1.0, color);

  // Smoother edges
  color *= smoothstep(0.5, 0.8, vUv.x);
  color /= smoothstep(0.5, 0.8, vUv.x);
  color *= smoothstep(0.5, 0.8, vUv.y);
  color /= smoothstep(0.5, 0.8, vUv.y);

  mixedColor = uColor;
  gl_FragColor = vec4(uColor, holographic / 8.0);

    #include <tonemapping_fragment>
    #include <colorspace_fragment>
}