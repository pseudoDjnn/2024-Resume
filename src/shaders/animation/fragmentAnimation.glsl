#define PI 3.1415926535897932384626433832795
#define nOcts 0

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
// #include ../includes/lights/ambientLight.glsl
// #include ../includes/lights/directionalLight.glsl
// #include ../includes/effects/halftone.glsl
// #include ../includes/effects/boxFrame.glsl

float parabola(float x, float k) {
  return pow(4.0 * x * (1.0 - x), k);
}

float quinticPolynomial(float x) {
  return x * x * x * (x * (x * 6.0 - 15.0) + 1.0);
}

float integralSmoothstep(float x, float T) {
  if (x > T)
    return x - T / 2.0;
  return x * x * x * (1.0 - x * 0.5 / T) / T / T;
}

float expStep(float x, float k, float n) {
  return exp(-k * pow(x, n));
}

vec3 palette(float tone) {

  vec3 a = cos(vec3(0.5, 0.5, 0.5));
  vec3 b = sin(vec3(0.5, 0.5, 0.5));
  vec3 c = -sin(vec3(1.0, 0.7, 0.4));
  vec3 d = cos(vec3(0.00, 0.15, 0.20));

  return a + b * cos(6.28318 * (c + tone + d) + fract(uAudioFrequency));
}

vec3 getColor(float amount) {
  vec3 color = 0.5 + 0.5 * cos(uTime * (sin(vec3(0.0, 0.3, 0.8)) + -sin(amount) * cos(vec3(1.0, 1.0, 1.0))));
  return color * palette(amount * mod(uAudioFrequency, 0.5));
}

// mat2 m = mat2(0.8, 0.6, -0.6, 0.8);

// float fnoise(in float x, in float w) {
//   return random2D(vec2(x)) * smoothstep(1.0, 0.5, w);
// }

// float noise(in vec2 x);

// float fbm(vec2 p) {
//   float f = 0.0;
//   f += 0.5000 * random2D(p);
//   p * m * 2.02;
//   f += 0.2500 * random2D(p);
//   p * m * 2.03;
//   f += 0.1250 * random2D(p);
//   p * m * 2.01;
//   f += 0.0625 * random2D(p);
//   p * m * 2.01;
//   f /= 0.9375;
//   return f;
// }

// cubic polynomial
vec3 smin(float a, float b, float k) {
  float h = 1.0 - min(abs(a - b) / (6.0 * k), 1.0);
  float w = h * h * h;
  float m = w * 0.5;
  float s = w * k;
  return (a < b) ? vec3(a - s, m, k) : vec3(b - s, 1.0 - m, k);
}

// circular approximation
float cApprox(float a, float b, float k) {
  k *= 1.0 / (1.0 - sqrt(0.5));
  float h = max(k - abs(a - b), 0.0) / k;
  const float b2 = 13.0 / 4.0 - 4.0 * sqrt(0.5);
  const float b3 = 3.0 / 4.0 - 1.0 * sqrt(0.5);
  return min(a, b) - k * h * h * (h * b3 * (h - 4.0) + b2);
}

// float sdfCircle(vec3 p, float r) {
//   // srqt(pow(p.x,2.0)+pow(p.y,2.0))-r;
//   return length(p) - r;
// }

float sdBoxFrame(vec3 p, vec3 b, float e) {
  p = abs(p) - b;
  vec3 q = abs(p + e) - e;
  return min(min(length(max(vec3(p.x, q.y, q.z), 0.0)) + min(max(p.x, max(q.y, q.z)), 0.0), length(max(vec3(q.x, p.y, q.z), 0.0)) + min(max(q.x, max(p.y, q.z)), 0.0)), length(max(vec3(q.x, q.y, p.z), 0.0)) + min(max(q.x, max(q.y, p.z)), 0.0));
}

void main() {
  // vec2 vUv = gl_FragCoord.xy / uResolution;
  // vUv = vUv - 0.5;
  // // vUv = vUv * 2.0;
  // vUv = vUv * uResolution / 100.0;

  // // Base color
  vec3 viewDirection = normalize(vPosition + cameraPosition);
  // // vec3 frame = calcNormal(viewDirection);
  // // float mixedStrength = (vElevation + uColorOffset) * uColorMultiplier;
  // // mixedStrength = smoothstep(0.0, 1.0, mixedStrength);
  // // vec3 color = mix(uDepthColor, uSurfaceColor, mixedStrength);

  vec3 color = uColor;

  // // vec2 st = gl_FragCoord.xy / uResolution.xy;
  // // st += st * abs(sin(uTime * 0.1) * 3.0);
  // vec3 black = vec3(0.0);
  // vec3 white = vec3(1.0);
  // vec3 red = vec3(1.0, 0.0, 0.0);
  // vec3 blue = vec3(0.65, 0.85, 1.0);
  // vec3 orange = vec3(0.9, 0.6, 0.3);
  // vec3 color = orange;
  // color = vec3(vUv.x, vUv.y, 0.0);
  // // st.x *= uResolution.x / uResolution.y;

  // // Draw sdf circle
  // float radius = 2.5;
  // vec2 center = vec2(0.0, 0.0);
  // // center = vec2(sin(2.0 * uTime), 0.0);
  // float distanceToCircle = sdfCircle(vUv - center, radius);
  // color = distanceToCircle > 0.0 ? orange : blue;

  // vec2 q = vec2(0.0);
  // q.x = fbm(st + 0.00 * uTime);
  // q.y = fbm(st + vec2(1.0));

  // vec2 r = vec2(0.0);
  // r.x = fbm(st + 1.0 * q + vec2(1.7, 9.2) + 0.15 * uTime);
  // r.y = fbm(st + 1.0 * q + vec2(8.3, 2.8) + 0.126 * uTime);

  // float f = fbm(st + r);

  // color = mix(vec3(0.101961, 0.619608, 0.666667), vec3(0.666667, 0.666667, 0.498039), clamp((f * f) * 4.0, 0.0, 1.0));

  // color = mix(color, vec3(0, 0, 0.164706), clamp(length(q), 0.0, 1.0));

  // color = mix(color, vec3(0.666667, 1, 1), clamp(length(r.x), 0.0, 1.0));

  // Normal
  vec3 normal = normalize(vNormal);
  if (!gl_FrontFacing)
    normal *= -1.0;

  // Randoms
  // float strength = random2D(vUv * vRandom * 89.0);

  // Strips
  float stripes = mod((vPosition.y - uTime) * 21.0, 1.0);
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
  // color *= parabola(uTime * holographic * uAudioFrequency, 1.0);

  // Smoother edges
  color *= smoothstep(0.0, 0.1, vUv.x);
  color *= smoothstep(-1.0, 0.1, vUv.x);
  color *= smoothstep(0.0, 0.1, vUv.y);
  color *= smoothstep(-1.0, 0.1, vUv.y);

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

  vec2 uv = vUv * 4.0;
  vec2 uv0 = uv;
  vec3 finalColor = vec3(0.0);
  float radius = 2.5;
  float box = sdBoxFrame(viewDirection, color, radius * uAudioFrequency);

  float minimumDistance = 1.0;

  for (float i = 0.0; i < 5.0; i++) {
    uv = fract(uv * 1.5) - 0.5;

    float distanceToCenter = length(uv) * exp(-length(uv0));

    vec3 colorLoop = getColor(length(uv0) + i * 0.5 * distance(length(uAudioFrequency * 0.2), minimumDistance));

    minimumDistance = max(minimumDistance, distanceToCenter);

    distanceToCenter = sin(distanceToCenter * 8.0 + pow(uAudioFrequency * 0.1, box)) / 8.0;
    distanceToCenter = abs(length(distanceToCenter));

    distanceToCenter = integralSmoothstep(0.01 / distanceToCenter, 0.5);

    // distanceToCenter = smoothstep(0.2, 0.5, distanceToCenter);

    finalColor += colorLoop * distanceToCenter;
  }

  // color += ffbm(holographic * 3.0);
  // finalColor += color;

  // color = mix(finalColor, color, finalColor);

  color += smin(stripes, falloff * uAudioFrequency * 0.2, fresnel);
  color += cApprox(stripes, uTime, fresnel);
  color *= finalColor;
  // color *= uTime + box;

  // finalColor -= step(0.8, abs(sin(55.0 * minimumDistance))) * 0.3;
  // finalColor = smoothstep(0.3, 0.8, finalColor);
  // fragColor = vec4(finalColor, 1.0);

  // Final color
  gl_FragColor = vec4(color, holographic);
    #include <tonemapping_fragment>
    #include <colorspace_fragment>
}

// void main() {
//   vec2 uv = gl_FragCoord.xy / uResolution;
//   uv = uv - 0.5;
//   // uv = uv * 2.0;
//   uv = uv * uResolution / 100.0;

//   vec3 black = vec3(0.0);
//   vec3 white = vec3(1.0);
//   vec3 red = vec3(1.0, 0.0, 0.0);
//   vec3 blue = vec3(0.65, 0.85, 1.0);
//   vec3 orange = vec3(0.9, 0.6, 0.3);
//   vec3 color = black;
//   color = vec3(uv.x, uv.y, 0.0);

//   // Draw sdf circle
//   float radius = 2.5;
//   vec2 center = vec2(0.0, 0.0);
//   center = vec2(sin(2.0 * uTime), 0.0);
//   float distanceToCircle = sdfCircle(uv - center, radius);
//   color = distanceToCircle > 0.0 ? orange : blue;

// // Add a black outline to the circle
//   color = color * (1.0 - exp(-2.0 * abs(distanceToCircle)));

//   // adding waves
//   color = color * 0.8 + color * 0.2 * sin(50.0 * distanceToCircle - 4.0 * uTime);

//   // adding a whtie border
//   color = mix(white, color, 2.0 * abs(distanceToCircle));

//   gl_FragColor = vec4(color, 1.0);
// }