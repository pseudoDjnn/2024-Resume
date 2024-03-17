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

  float strength = random(vUv * vRandom);

  vec3 blackColor = vec3(0.0);
  vec3 uvColor = vec3(vUv, uColor);
  vec3 mixedColor = mix(blackColor, uvColor, strength);

  // Color Remap
  mixedColors = smoothstep(0.7, 1.0, mixedColors);

  // Smoother edges
  mixedColors *= smoothstep(0.0, 0.1, vUv.x);
  mixedColors *= smoothstep(0.4, 1.0, vUv.x);
  mixedColors *= smoothstep(0.0, 0.1, vUv.y);
  mixedColors *= smoothstep(0.4, 1.0, vUv.y);

  mixedColor = color;
  gl_FragColor = vec4(color, 0.03);

    #include <tonemapping_fragment>
    // #include <colorspace_fragment>
}