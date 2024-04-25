#define PI 3.1415926535897932384626433832795

uniform vec3 uMouse;
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
#include ../includes/effects/voronoi.glsl
// #include ../includes/lights/ambientLight.glsl
// #include ../includes/lights/directionalLight.glsl
// #include ../includes/effects/halftone.glsl
// #include ../includes/effects/boxFrame.glsl

float lerp(float t) {
  float v1 = t * t;
  float v2 = 1.0 - (1.0 - t) * (1.0 - t);
  return smoothstep(v1, v2, smoothstep(0.0, 0.1, t));
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

  return a + b * cos(6.28318 * (c + tone + d));
}

vec3 getColor(float amount) {
  vec3 color = 0.5 + 0.5 * cos(6.2831 * (sin(vec3(0.0, 0.1, 0.2)) * tan(amount) * cos(vec3(1.0, 1.0, 1.0))));
  return color * palette(amount);
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

mat2 rot2d(float angle) {
  float s = sin(angle);
  float c = cos(angle);
  return mat2(c, -s, s, c);
}

float polynomialSMin(float a, float b, float k) {
  float h = clamp(0.5 + 0.5 * (b - a) / k, 0.0, 1.0);
  return mix(b, a, h) - k * h * (1.0 - h);
}

float smoothMax(float a, float b, float k) {
  return log(exp(k * a) + exp(k * b)) / k;
}

float smoothMin(float a, float b, float k) {
  return -smoothMax(-a, -b, k);
}

float sdSphere(vec3 position, float radius) {
  return length(position) - radius;
}

float sdBox(vec3 position, vec3 b) {
  vec3 q = abs(position) - b;
  return length(max(q, 0.0)) + min(max(q.x, max(q.y, q.z)), uTime * uTime * uAudioFrequency * 8.0);
}

float opTwist(vec3 p, float k, float twistAmount) {
  float angle = k * p.y * twistAmount;
  // Calculate a twist factor based on angle (modify as needed)
  float twist = abs(sin(angle)); // Example using absolute value of sine
  return twist;
}

float sdGyroid(vec3 position, float h) {
  return abs(dot(uAudioFrequency * 0.8 * sin(position), cos(position.zxy))) - h;
}

float sdOctahedron(vec3 p, float s) {
  p = abs(p);
  float m = p.x + p.y + p.z - s;
  vec3 q;
  if (3.0 * p.x < m)
    q = p.xyz;
  else if (3.0 * p.y < m)
    q = p.yzx;
  else if (3.0 * p.z < m)
    q = p.zxy;
  else
    return m * 0.57735027;

  float k = clamp(0.5 * (q.z - q.y + s), 0.0, s);
  return length(vec3(q.x, q.y - s + k, q.z - k));
}

float sdPyramid(vec3 p, float h) {
  float m2 = h * h + 0.25;

  p.xz = abs(p.xz);
  p.xz = (p.z > p.x) ? p.zx : p.xz;
  p.xz -= 0.5;

  vec3 q = vec3(p.z, h * p.y - 0.5 * p.x, h * p.x + 0.5 * p.y);

  float s = max(-q.x, 0.0);
  float t = clamp((q.y - 0.5 * p.z) / (m2 + 0.25), 0.0, 1.0);

  float a = m2 * (q.x + s) * (q.x + s) + q.y * q.y;
  float b = m2 * (q.x + 0.5 * t) * (q.x + 0.5 * t) + (q.y - m2 * t) * (q.y - m2 * t);

  float d2 = min(q.y, -q.x * m2 - q.y * 0.5) > 0.0 ? 0.0 : min(a, b);

  return sqrt((d2 + q.z * q.z) / m2) * sign(max(q.z, -p.y));
}

float opDisplace(float d1, float d2) {
  return d1 + d2;
}

float opCheapBend(vec3 p, float k) {
  float s = sin(k * p.x);
  float c = cos(k * p.x);
  // Calculate bend based on matrix multiplication (modify as needed)
  mat2x2 m = mat2x2(vec2(c, s), vec2(-s, c));
  float bend = dot(vec2(p.x, p.y), vec2(m[0][0], m[0][1])); // Example using dot product
  return bend;
}

float sdf(vec3 position) {
  vec3 shapesPosition = vec3(sin(uTime * 0.01) * 1.5, -1.0, 0.3);
  // vec3 shapesPosition2 = vec3(sin(uAudioFrequency) * 1.0, 0.0, 0.3);
  // float voroCopy = voroNoise(shapePosition, 0.0, 0.0);

  // Various rotational speeds
  vec3 position1 = rotate(position, vec3(1.0), -uTime / 5.0);
  // position1 += polynomialSMin(uAudioFrequency * 0.003, dot(sqrt(uAudioFrequency * 0.02), 0.3), 0.3);

  vec3 position2 = rotate(position - shapesPosition * 0.5, vec3(1.0), uAudioFrequency * 0.003);

  vec3 position3 = rotate(position, vec3(1.0), cos(-uTime * 0.1 * PI));

  // Copied position used to make the actual copyPosition 
  vec3 position4 = rotate(position, vec3(1.0), uTime * 0.5 * sin(uAudioFrequency * 0.0001) * cos(uAudioFrequency * 0.0001));
  // position4 = getColor(uTime * 0.02);

// Copy of the vec3 position
  vec3 copyPosition = position4 - shapesPosition;
  vec3 copyPositionRotation = fract(uAudioFrequency * PI * 2.0 * rotate(copyPosition, vec3(1.0), fract(uTime / 8.0) * cos(uAudioFrequency * 0.02)));
  copyPosition.z += uTime * 0.5;
  copyPosition.xy = sin(fract(copyPositionRotation.xy * uAudioFrequency) - 0.5);
  copyPosition.z = mod(position.z, 0.21) - 0.144;

// Shapes used 
  float morphedShaped = polynomialSMin(sdBox(position3, vec3(0.2)), sdOctahedron(position1, 0.8), max(sdSphere(position1, 0.5), 0.5 * sdGyroid((position1 + vec3(2.0)) * 21.5 + uTime, 0.2) / -21.5));
  // morphedShaped += opDisplace(uTime, uAudioFrequency);
  // TODO: Work on this tomorrow
  // float morphedPrism = polynomialSMin(sdSphere(position, 0.2), sdHexPrism(position3, vec2(0.3)), sdOctahedron(position3, 0.8));
  // float morphedShaped2 = polynomialSMin(sdHexPrism(position1, vec2(0.2)), sdTriPrism(position1, vec2(0.5)), sdSphere(copyPosition - position2, 0.5));
  float morphedShaped2 = polynomialSMin(sdPyramid(position2, min(uAudioFrequency, 0.5)), sdOctahedron(position2, 0.8), sdSphere(position2, 0.5));
  float pyramid = sdPyramid(position2, 0.8);

  float test = max(sdSphere(position1, 0.8), 0.5 * sdGyroid((position1 + vec3(2.0)) * 21.5, 0.2) / 21.5);
  // morphedPrism = min(morphedPrism, w.w + sdHexPrism(w.xyz, vec2(0.2, 0.1)));
  // float morphedMin = polynomialSMin(uAudioFrequency, morphedPrism, 0.8);

  float finalShape = mix(morphedShaped, morphedShaped2, 0.1);
  // finalShape = opOnion(morphedSphere, morphedShaped);

  // return sdSphere(position, 0.5);

  int i;
  for (i = 0; i < 10; i++) {
    float random = random2D(vec2(i, 0.0));
    // float randomV = voroNoise(position, 0.1, 1.0);
    float progress = 1.0 - fract(uTime / 5.0 + random * 5.0);
    vec3 positionLoop = vec3(sin(random * 2.0 * PI), cos(random * 2.0 * PI), atan(random * 2.0 * PI));

    float goToCenter = sdSphere(copyPosition - positionLoop * progress, 0.02);
    // float morphLoop = sdBoxFrame();
    // goToCenter = opOnion(finalShape, morphedShaped);
    finalShape = polynomialSMin(finalShape, goToCenter, 0.02);
  }

  // float mouseSphere = sdSphere(position - vec3(uMouse.xy * 2.0, 0.3), 0.1);

  float ground = position.y + .34;
  // ground = getColor(0.0);

  return polynomialSMin(ground, polynomialSMin(finalShape, 0.1, 0.1), 0.1);
}

vec3 calcNormal(in vec3 popsition) {
  const float epsilon = 0.00001;
  const vec2 h = vec2(epsilon, 0);
  return normalize(vec3(sdf(popsition + h.xyy) - sdf(popsition - h.xyy), sdf(popsition + h.yxy) - sdf(popsition - h.yxy), sdf(popsition + h.yyx) - sdf(popsition - h.yyx)));
}

void main() {

  vec3 viewDirection = normalize(vPosition + cameraPosition);
    // vec3 color = uColor;
  vec3 normal = normalize(vNormal);
  if (!gl_FrontFacing)
    normal *= -1.0;

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

  // Background
  float dist = length(vUv - vec2(0.5));
  vec3 background = cos(mix(vec3(0.0), vec3(0.3), dist));
  vec3 sphereColor = 0.5 + 0.5 * cos(uAudioFrequency * 0.02 + uTime * 0.2 + vUv.xyx + vec3(0, 2, 4));

  vec2 uv0 = vUv * 4.0;
  vec2 uv1 = uv0;
  vec3 finalColor = vec3(0.0);
  float radius = 2.5;

  float minimumDistance = 1.0;

  for (float i = 0.0; i < 5.0; i++) {
    uv0 = fract(uv0 * 1.5) - 0.5;

    float distanceToCenter = length(uv0) * exp(-length(uv1));

    vec3 colorLoop = getColor(length(uv1) + i * 0.5 * sqrt(dot(length(uAudioFrequency * 0.02), minimumDistance)) * 0.5);

    minimumDistance = min(minimumDistance, distanceToCenter);

    distanceToCenter = sin(distanceToCenter * 8.0 + min(uAudioFrequency * 0.001, uTime)) / 8.0;
    distanceToCenter = abs(length(distanceToCenter));

    distanceToCenter = pow(0.01 / distanceToCenter, 0.5);

    // distanceToCenter = smoothstep(0.2, 0.5, distanceToCenter);

    finalColor += colorLoop * distanceToCenter;
  }

  // Use new UV
  vec2 newUv = (vUv - vec2(0.5)) + vec2(0.5);
  // Create position of camera
  vec3 camPos = vec3(0.0, 0.0, 2.0);
  // Cast ray form camera to sphere
  vec3 ray = normalize(vec3((newUv - vec2(0.5)), -1));
  // Color creation
  vec3 color = background;

  // Start the march
  vec3 raypos = camPos;
  // Distance travelled
  float t = 0.0;
  float tMax = 2.0;

  // vec2 m = (uMouse.xy * 2. - uResolution.xy) / uResolution.y;

  // if (uMouse.z < 0.0) {
  //   m = vec2(cos(uTime * 0.2), sin(uTime * 0.2));
  // }

  int i;
  for (i = 0; i < 256; i++) {
    // The position along the ray
    vec3 position = raypos + t * ray;
    // float voroPosition = voroNoise(position, t,tMax);
    // pos.xy *= rotate(pos.xy, vec3(1.0), uTime);
    position.xy *= rot2d(t * 0.2 * uMouse.x);
    position.y += sin(t * (uMouse.y - 0.5) * 0.5) * 0.13;
    // The Current distance to the scene
    float h = sdf(position);
    // The "march" of the ray
    t += h;
    if (h < 0.0001 || t > tMax)
      break;
    // camPos *= finalColor;
    // color = getColor(tMax * 0.4 + float(i) * 0.005);
    color = 1.0 - getColor(uTime * 0.01 + t * 0.5 + uAudioFrequency * 0.02);

  }

  if (t < tMax) {
    vec3 position = camPos + t * ray;
    // position.x += sin(t * (uMouse.x - 0.5) * 0.5) * 0.89;
    color = vec3(1.0);
    vec3 normal = calcNormal(position);
    color = normal;
    float diff = dot(vec3(1.0), normal * uTime);
    color = vec3(diff);

    float fresnel = pow(1.5 + dot(ray, normal), 3.0);
    color = vec3(fresnel);

    color = vec3(float(i) / 235.0);
    color = mix(color, (1.0 - sphereColor * background), fresnel);

    // color *= smoothstep(0.0, 0.1, vUv.x);
    // color *= smoothstep(-1.0, 0.1, vUv.x);
    // color *= smoothstep(0.0, 0.1, vUv.y);
    // color *= smoothstep(-1.0, 0.1, vUv.y);
    // color *= finalColor;
  }

  gl_FragColor = vec4(color, 1.0);
    #include <tonemapping_fragment>
    #include <colorspace_fragment>
}