#define PI 3.1415926535897932384626433832795

uniform vec2 uMouse;
uniform vec4 uResolution;
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

float lerp(float t) {
  float v1 = t * t;
  float v2 = 1.0 - (1.0 - t) * (1.0 - t);
  return smoothstep(v1, v2, smoothstep(0.3, 1.0, t));
}

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
  vec3 color = 0.5 + 0.5 * sin(uTime * (sin(vec3(0.2, 0.3, 0.8)) * tan(amount) * cos(vec3(1.0, 1.0, 1.0))));
  return color * palette(amount + min(uAudioFrequency * 0.1, 0.5));
}

// cubic polynomial
vec3 smin(float a, float b, float k) {
  float h = 1.0 - min(abs(a - b) / (6.0 * k), 1.0);
  float w = h * h * h;
  float m = w * 0.5;
  float s = w * k;
  return (a < b) ? vec3(a - s, m, s) : vec3(b - s, 1.0 - m, s);
}

// circular approximation
float cApprox(float a, float b, float k) {
  k *= 1.0 / (1.0 - sqrt(0.5));
  float h = max(k - abs(a - b), 0.0) / k;
  const float b2 = 13.0 / 4.0 - 4.0 * sqrt(0.5);
  const float b3 = 3.0 / 4.0 - 1.0 * sqrt(0.5);
  return min(a, b) - k * h * h * (h * b3 * (h - 4.0) + b2);
}

// void main() {

//   // // Base color
//   vec3 viewDirection = normalize(vPosition + cameraPosition);
//   // // vec3 frame = calcNormal(viewDirection);
//   // // float mixedStrength = (vElevation + uColorOffset) * uColorMultiplier;
//   // // mixedStrength = smoothstep(0.0, 1.0, mixedStrength);
//   // // vec3 color = mix(uDepthColor, uSurfaceColor, mixedStrength);

//   vec3 color = uColor;

//   // // vec2 st = gl_FragCoord.xy / uResolution.xy;
//   // // st += st * abs(sin(uTime * 0.1) * 3.0);
//   // vec3 black = vec3(0.0);
//   // vec3 white = vec3(1.0);
//   // vec3 red = vec3(1.0, 0.0, 0.0);
//   // vec3 blue = vec3(0.65, 0.85, 1.0);
//   // vec3 orange = vec3(0.9, 0.6, 0.3);
//   // vec3 color = orange;
//   // color = vec3(vUv.x, vUv.y, 0.0);
//   // // st.x *= uResolution.x / uResolution.y;

//   // // Draw sdf circle
//   // float radius = 2.5;
//   // vec2 center = vec2(0.0, 0.0);
//   // // center = vec2(sin(2.0 * uTime), 0.0);
//   // float distanceToCircle = sdfCircle(vUv - center, radius);
//   // color = distanceToCircle > 0.0 ? orange : blue;

//   // vec2 q = vec2(0.0);
//   // q.x = fbm(st + 0.00 * uTime);
//   // q.y = fbm(st + vec2(1.0));

//   // vec2 r = vec2(0.0);
//   // r.x = fbm(st + 1.0 * q + vec2(1.7, 9.2) + 0.15 * uTime);
//   // r.y = fbm(st + 1.0 * q + vec2(8.3, 2.8) + 0.126 * uTime);

//   // float f = fbm(st + r);

//   // color = mix(vec3(0.101961, 0.619608, 0.666667), vec3(0.666667, 0.666667, 0.498039), clamp((f * f) * 4.0, 0.0, 1.0));

//   // color = mix(color, vec3(0, 0, 0.164706), clamp(length(q), 0.0, 1.0));

//   // color = mix(color, vec3(0.666667, 1, 1), clamp(length(r.x), 0.0, 1.0));

//   // Normal
//   vec3 normal = normalize(vNormal);
//   if (!gl_FrontFacing)
//     normal *= -1.0;

//   // Randoms
//   // float strength = random2D(vUv * vRandom * 89.0);

//   // Strips
//   float stripes = mod((vPosition.y - uTime) * 21.0, 1.0);
//   stripes = pow(stripes, 3.0);

//   // Fresnel
//   float fresnel = dot(viewDirection, normal) + 1.0;
//   fresnel = pow(fresnel, 2.0);

//   // Falloff
//   float falloff = smoothstep(0.8, 0.0, fresnel);

//   // Holographic
//   float holographic = stripes * fresnel;
//   holographic += fresnel * 1.21;
//   holographic *= falloff;
//   // holographic *= palette(holographic);

//   // Color mixing
//   // vec3 blackColor = vec3(0.0);
//   // vec3 uvColor = vec3(vUv, strength);
//   // vec3 mixedColor = mix(blackColor, uvColor, color);

//   // Color Remap
//   // color = smoothstep(0.3, 0.8, color * uAudioFrequency);
//   // color *= parabola(uTime * holographic * uAudioFrequency, 1.0);

//   // Smoother edges
//   color *= smoothstep(0.0, 0.1, vUv.x);
//   color *= smoothstep(-1.0, 0.1, vUv.x);
//   color *= smoothstep(0.0, 0.1, vUv.y);
//   color *= smoothstep(-1.0, 0.1, vUv.y);

//   // Lights
//   // vec3 light = vec3(0.0);

//   // light += ambientLight(vec3(1.0), 1.0);
//   // light += directionalLight(vec3(1.0, 0.0, 0.5), 1.0, normal, vec3(0.0, 0.25, 0.0), viewDirection, 1.0);

//   // color *= light;

//   // color = mixedColor;
//   // mixedColor = color;

//   // Halftone
//   // color = halftone(color, uShadowRepetitions, vec3(0.0, -1.0, 0.0), -0.8, 1.5, uShadowColor, normal);
//   // color = halftone(color, uLightRepetitions, vec3(1.0, 1.0, 0.0), 0.5, 1.5, uLightColor, normal);

//   // color = mix(color, pointColor, color);

//   // vec2 uv = gl_PointCoord;
//   // float distanceToCenter = length(uv - vec2(0.5));

//   // if (distanceToCenter > 0.5)
//   //   discard; 

//   vec2 uv0 = vUv * 4.0;
//   vec2 uv1 = uv0;
//   vec3 finalColor = vec3(0.0);
//   float radius = 2.5;
//   // float box = sdBoxFrame(viewDirection, color, radius * uAudioFrequency);

//   float minimumDistance = 1.0;

//   for (float i = 0.0; i < 5.0; i++) {
//     uv0 = fract(uv0 * 1.5) - 0.5;

//     float distanceToCenter = length(uv0) * exp(-length(uv1));

//     vec3 colorLoop = getColor(length(uv1) + i * 0.5 * distance(length(uAudioFrequency * 0.02), minimumDistance) * 0.5);

//     minimumDistance = min(minimumDistance, distanceToCenter);

//     distanceToCenter = sin(distanceToCenter * 8.0 + min(uAudioFrequency * 0.01, uTime)) / 8.0;
//     distanceToCenter = abs(length(distanceToCenter));

//     distanceToCenter = integralSmoothstep(0.01 / distanceToCenter, 0.5);

//     // distanceToCenter = smoothstep(0.2, 0.5, distanceToCenter);

//     finalColor += colorLoop * distanceToCenter;
//   }

//   // color += ffbm(holographic * 3.0);
//   // finalColor += color;

//   // color = mix(finalColor, color, finalColor);

//   color += smin(stripes, holographic * uAudioFrequency * 0.1, fresnel);
//   // color += cApprox(stripes, uTime, fresnel);
//   color *= finalColor;
//   // color *= uTime + box;

//   // finalColor -= step(0.8, abs(sin(55.0 * minimumDistance))) * 0.3;
//   // finalColor = smoothstep(0.3, 0.8, finalColor);
//   // fragColor = vec4(finalColor, 1.0);

//   // Final color
//   gl_FragColor = vec4(color, holographic);
//     #include <tonemapping_fragment>
//     #include <colorspace_fragment>
// }

mat4 rotationMatrix(vec3 axis, float angle) {
  axis = normalize(axis);
  float s = sin(angle);
  float c = cos(angle);
  float oc = 1.0 - c;

  return mat4(oc * axis.x * axis.x + c, oc * axis.x * axis.y - axis.z * s, oc * axis.z * axis.x + axis.y * s, 0.0, oc * axis.x * axis.y + axis.z * s, oc * axis.y * axis.y + c, oc * axis.y * axis.z - axis.x * s, 0.0, oc * axis.z * axis.x - axis.y * s, oc * axis.y * axis.z + axis.x * s, oc * axis.z * axis.z + c, 0.0, 0.0, 0.0, 0.0, 1.0);
}

vec3 rotate(vec3 v, vec3 axis, float angle) {
  mat4 m = rotationMatrix(axis, angle);
  return (m * vec4(v, 1.0)).xyz;
}

float polynominalSMin(float a, float b, float k) {
  float h = clamp(0.5 + 0.5 * (b - a) / k, 0.0, 1.0);
  return mix(b, a, h) - k * h * (1.0 - h);
}

float sdSphere(vec3 position, float radius) {
  return length(position) - radius;
}

float sdBox(vec3 position, vec3 b) {
  vec3 q = abs(position) - b;
  return length(max(q, 0.0)) + min(max(q.x, max(q.y, q.z)), 0.0);
}

float sdf(vec3 position) {
  vec3 position1 = rotate(position, vec3(2.0), uTime / 5.0);
  float box = polynominalSMin(sdBox(position1, vec3(0.2)), sdSphere(position, 0.2), uAudioFrequency * 0.2);

  float sphere = sdSphere(position1, 0.3);
  float final = mix(box, sphere, uAudioFrequency * 0.1);
  // return sdSphere(position, 0.5);

  for (float i = 0.0; i < 10.0; i++) {
    float random = random2D(vec2(i, 0.0));
    float progress = 1.0 - fract(uTime / 3.0 + random * 3.0);
    vec3 positionLoop = vec3(sin(random * 2.0 * PI), cos(random * 2.0 * PI), 0.0);
    float goToCenter = sdSphere(position - positionLoop * progress, 0.1);
    final = polynominalSMin(final, goToCenter, 0.3);

  }

  return polynominalSMin(final, sphere, 0.1);
}

vec3 calcNormal(in vec3 popsition) {
  const float epsilon = 0.001;
  const vec2 h = vec2(epsilon, 0);
  return normalize(vec3(sdf(popsition + h.xyy) - sdf(popsition - h.xyy), sdf(popsition + h.yxy) - sdf(popsition - h.yxy), sdf(popsition + h.yyx) - sdf(popsition - h.yyx)));
}

void main() {

  // background
  float dist = length(vUv - vec2(0.5));
  vec3 background = mix(vec3(0.3), vec3(0.0), dist);

  // Use new UV
  vec2 newUv = (vUv - vec2(0.5)) * uResolution.zw + vec2(0.5);
  // Create position of camera
  vec3 camPos = vec3(0.0, 0.0, 2.0);
  // Cast ray form camera to sphere
  vec3 ray = normalize(vec3(vUv - vec2(0.5), -1));

  // Start the march
  vec3 raypos = camPos;
  float t = 0.0;
  float tMax = 5.0;
  for (int i = 0; i < 256; i++) {
    vec3 pos = camPos + t * ray;
    float h = sdf(pos);
    if (h < 0.0001 || t > tMax)
      break;
    t += h;
  }

  vec3 color = background;
  if (t < tMax) {
    vec3 position = camPos + t * ray;
    color = vec3(1.0);
    vec3 normal = calcNormal(position);
    color = normal;
    float diff = dot(vec3(1.0), normal);
    color = vec3(diff);

    float fresnel = pow(1.0 + dot(ray, normal), 3.0);
    color = vec3(fresnel);

    color = mix(color, background, fresnel);
  }

  gl_FragColor = vec4(color, 1.0);
    #include <tonemapping_fragment>
    #include <colorspace_fragment>
}