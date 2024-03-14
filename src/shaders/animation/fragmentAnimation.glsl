precision mediump float;

uniform vec3 uColor;
uniform vec3 uDepthColor;
uniform vec3 uSurfaceColor;
uniform float uColorOffset;
uniform float uColorMultiplier;

varying float vRandom;
varying float vElevation;
varying vec2 vUv;

float random(vec2 st) {
  return fract(sin(dot(st.xy, vec2(12.9898, 78.233))) * 43758.5453123);
}

void main() {

  float mixedColors = (vElevation + uColorOffset) * uColorMultiplier;

  vec3 color = mix(uDepthColor, uSurfaceColor, mixedColors);

  float strength = random(vUv);
  // float perlin = step(0.9, sin(cnoise(vec3(vUv, strength * 5.0))));

  // perlin = clamp(perlin, 0.0, 1.0);

  vec3 blackColor = vec3(0.0);
  vec3 uvColor = vec3(vUv, uColor);
  vec3 mixedColor = mix(blackColor, uvColor, strength);

  mixedColor = color;
  gl_FragColor = vec4(color, 0.003);

    // #include <colorspace_fragment>
}