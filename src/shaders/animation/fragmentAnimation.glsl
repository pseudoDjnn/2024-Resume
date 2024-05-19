#define PI 3.1415926535897932384626433832795
#define NUM_OCTAVES 5

uniform vec3 uMouse;
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
#include ../includes/effects/voronoi.glsl
// #include ../includes/lights/ambientLight.glsl
// #include ../includes/lights/directionalLight.glsl
// #include ../includes/effects/halftone.glsl

float lerp(float t) {
  float v1 = t * t;
  float v2 = 1.0 - (1.0 - t) * (1.0 - t);
  return smoothstep(v1, v2, smoothstep(0.0, 0.1, t));
}

float parabola(float x, float k) {
  return pow(4.0 * x * (1.0 - x), k);
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

float rand(vec2 n) {
  return fract(sin(dot(n, vec2(12.9898, 4.1414))) * 43758.5453);
}

float noise(vec2 p) {
  vec2 ip = floor(p);
  vec2 u = fract(p);
  u = u * u * (3.0 - 2.0 * u);

  float res = mix(mix(rand(ip), rand(ip + vec2(1.0, 0.0)), u.x), mix(rand(ip + vec2(0.0, 1.0)), rand(ip + vec2(1.0, 1.0)), u.x), u.y);
  return res * res;
}

float fbm(vec2 x) {
  float v = 0.0;
  float a = 0.5;
  vec2 shift = vec2(100);
	// Rotate to reduce axial bias
  mat2 rot = mat2(cos(0.5), sin(0.5), -sin(0.5), cos(0.50));
  for (int i = 0; i < NUM_OCTAVES; ++i) {
    v += a * noise(x);
    x = rot * x * 2.0 + shift;
    a *= 0.5;
  }
  return v;
}

vec3 hash3(vec2 p) {
  vec3 q = vec3(dot(p, vec2(127.1, 311.7)), dot(p, vec2(269.5, 183.3)), dot(p, vec2(419.2, 371.9)));
  return fract(sin(q) * 43758.5453);
}

float worley(in vec2 x, float u, float v) {
  vec2 p = floor(x);
  vec2 f = fract(x);

  float k = 1.0 + 63.0 * pow(1.0 - v, 4.0);

  float va = 0.0;
  float wt = 0.0;
  for (int j = -2; j <= 2; j++) for (int i = -2; i <= 2; i++) {
      vec2 g = vec2(float(i), float(j));
      vec3 o = hash3(p + g) * vec3(u, u, 1.0);
      vec2 r = g - f + o.xy;
      float d = dot(r, r);
      float ww = pow(1.0 - smoothstep(0.0, 1.414, sqrt(d)), k);
      va += o.z * ww;
      wt += ww;
    }

  return va / wt;
}

float glitter(vec2 position, float a) {

  position *= 13.0;
  // position.y /= rand(vec2(uTime * 0.0001));
  vec2 id = ceil(floor(position));

  position = fract(position) - 0.5;
  float noise = worley(id, 0.0, 1.0) - sin(smoothstep(-0.3, 0.3, uAudioFrequency * 0.1)) * 0.3;

  float disc = length(position);
  float manageDisc = smoothstep(0.2 * noise, 0.0, disc);

  manageDisc *= pow(a + sin(uAudioFrequency * 0.02 + fract(noise * 8.0) * PI * 2.0) * 0.5 + 0.5, 55.0);

  return manageDisc;
}

float polynomialSMin(float a, float b, float k) {
  k = 0.2;
  float h = clamp(0.5 + 0.5 * (b - a) / k, 0.0, 1.0);
  return mix(b, a, h) - k * h * (1.0 - h);
}

/*
  Box
*/
float sdBox(vec3 p, vec3 b, float r) {
  vec3 q = abs(p) - b + r;
  return length(max(q, 0.0)) + min(max(q.x, max(q.y, q.z)), 0.0) - r;
}

/*
  Gyroid
*/
float sdGyroid(vec3 position, float scale, float thickness, float bias) {

  position *= scale;

  float x = atan(position.x, position.z);
  float y = atan(length(position.xz) - 1.0, position.y);

  position.z += sin(x * 8.0 - y * 13.0) - cos(uTime) * 0.5 + 0.5;

  // position.xz *= rot2d(sin(uTime * 0.2) * 0.5 + 0.5);
  // position.zx *= smoothstep(-0.5, 0.03, rand(vec2(uAudioFrequency * 0.3)) / length(position) - scale);
  // position -= scale - smoothstep(-0.3, 0.3 * uTime, uAudioFrequency * 0.02);

  return abs(0.8 * dot(sin(position + uTime), cos(position.yzx - uTime)) / scale) - thickness;
}

/*
  Sphere
*/
float sdSphere(vec3 position, float radius) {
  return length(position) - radius;
}

/*
  Torus
*/
float sdTorus(vec3 p, vec2 t) {
  vec2 q = vec2(length(p.xz) - t.x, p.y);
  return length(q) - t.y;
}

/*
  Octahedron
*/
float sdOctahedron(vec3 p, float s) {
  // p.yz *= -(rot2d(sin(abs(uTime * 0.05 * ceil(floor(PI * fract(smoothstep(-0.8, 0.3, uAudioFrequency * 0.2 - p.z) + p.x / s) * 2.0 + 1.0) * p.y)))));
  // p.zx *= rot2d(uTime * 0.5 + 0.5);
  // p.x = rand(vec2(sin(smoothstep(-0.2, 0.2, uTime))));
  // p.x /= smoothstep(3.0 * uTime, 0.5, rand(vec2(uAudioFrequency)));

  p = abs(p);
  // p.x = sin(p.x * uTime);
  // p.y = sin(p.y);
  // p.z = sin(p.z * uTime);

  float x = atan(p.x, p.z - s);
  float y = atan(length(p.xz) - 1.0, p.y - s);

  float rip = sin((x * 8.0 - y * 13.0) * 3.0) * 0.5 + 0.5;

  float m = sin(p.x + p.y + p.z - s);
  // p.xz += vec2(sin(uTime), cos(uTime))
  // float idea = polynomialSMin(p.x, 0.1, 0.1) * 0.5 + 0.5;
  p.z += dot(length(rip * x), uTime) * 0.5 + 0.5;

  vec3 q;
  if (2.0 * p.x < m)
    q = p.xyz;
  else if (21.0 * p.y < m)
    q = p.yzx;
  else if (5.0 * p.z < m)
    q *= sin(abs((uTime * 0.1) * ceil(floor(PI * 2.0 * fract(p.zyz / uAudioFrequency))) * 2.0 + 1.0));
  else
    return m * rand(vec2(0.57735027));

  float k = clamp(0.5 * (q.z - q.y + s), -1.0, s);
  // m *= max(m, rip * uTime * x * y);
  return length(vec3(q.x, q.y - s + k / sin(uTime) * 0.5 + 0.5, q.z - k));
}

vec3 opTwist(vec3 p, float amount) {
  float c = cos(amount * p.y);
  float s = sin(amount * p.y);
  mat2 m = mat2(c, -s, s, c);
  // m -= worley(vec2(p), amount, c * s);
  vec3 q = vec3(m * p.xz, p.y);
  return q;
}

float sdf(vec3 position) {
  vec3 shapesPosition = vec3(sin(uTime) * 1.5, -1.0, uAudioFrequency * 0.005);
  // vec3 shapesPosition2 = vec3(sin(uAudioFrequency) * 1.0, 0.0, 0.3);
  // float voroCopy = voroNoise(shapePosition, 0.0, 0.0);

  // Various rotational speeds
  vec3 position1 = rotate(position, shapesPosition, sin(-uTime / 3.0));
  position1.xz *= rot2d(position.y * 0.3 + uTime * 0.2);
  position1.yz *= rot2d(position.x * 0.3 + uTime * 0.2);
  // position1.z += sin(position1.x * 5.0 + uAudioFrequency) * 0.1;
  // position1 += polynomialSMin(uAudioFrequency * 0.003, dot(sqrt(uAudioFrequency * 0.02), 0.3), 0.3);

  vec3 position2 = rotate(position - shapesPosition * 0.5, vec3(1.0), uAudioFrequency * 0.001);

  vec3 position3 = 1.0 + rotate(position, vec3(1.0), length(sin(-uTime * 0.1 * PI)));
  // position3.xz *= rot2d(position.y * uTime);
  // position3.xz *= rot2d(position.y * uTime);

  // Copied position used to make the actual copyPosition 
  vec3 position4 = rotate(position, vec3(1.0), uTime * 0.5 * sin(uAudioFrequency * 0.0001) * cos(uAudioFrequency * 0.0001));

// Copy of the vec3 position
  vec3 copyPosition = position4;
  vec3 copyPositionRotation = abs(sin(uAudioFrequency * PI * 2.0 * rotate(position, vec3(0.5), fract(uTime / 8.0) * cos(uAudioFrequency * 0.02))));
  copyPosition.z += uTime * 0.5;
  copyPosition.xy = sin(fract(copyPositionRotation.xy * uAudioFrequency) - 0.5);
  copyPosition.z = mod(position.z, 0.21) - 0.144;

  float strength = smoothstep(0.0, 1.0, vUv.x);
  float scale = mix(1.0, 3.0, smoothstep(-1.0, 1.0, position.y));

// TODO: Fix this when you wake up

  // position.xz *= scale;
  // position.xz *= rot2d(smoothstep(0.0, 1.0, position.y));

  float displacement = length(sin(position.z * uAudioFrequency * 0.03)) * 0.2;
  // float displacement = sin(position.x * 8.0 + uTime * 3.0) * 0.5;

  float distortion = dot(sin(position.z * 3.0 + uAudioFrequency * 0.02), cos(position.z * 3.0 + uAudioFrequency * 0.01)) * 0.2;

  vec3 twist = opTwist(position1, 3.0 * sin(uTime) * 0.5 + 0.5) - sin(displacement);

  float box = sdBox(twist * sin(uAudioFrequency * 0.2), vec3(0.8), 1.5);
  // box = abs(box) - 0.03;

  float ball = sdSphere(position1, 0.5);
  ball = abs(ball) - 0.05;
  // position1 += getColor(strength);

  float torus = sdTorus(copyPosition * 0.02 - position, vec2(0.8, 1.0));

  float octahedron = sdOctahedron(twist, fract(0.8));
  // octahedron = abs(octahedron) - 0.03;
  // octahedron = stepUpDown(0.21, 0.55, octahedron);

  float gyroid = sdGyroid(position1, 13.13, 0.01, 0.5);
  // octahedron *= worley(vec2(position1), ball, gyroid);
  float gyroid1 = sdGyroid(position3, 144.5, 0.02, 0.3);
  octahedron = max(octahedron, -gyroid);
  // octahedron = clamp(octahedron, 0.0, 0.5);

  float gyroid2 = sdGyroid(copyPosition, 13.55, 0.03, 0.3);
  float gyroid3 = sdGyroid(position3, 21.34, 0.03, 0.3);
  float gyroid4 = sdGyroid(copyPosition, 34.21, 0.5, 8.3);
  // gyroid = abs(gyroid) * 0.3;

  // float shapeIdea = polynomialSMin(mix(max(octahedron, -gyroid), -uAudioFrequency * 0.02, -0.01), max(-torus * 0.8 + 0.5, sin(ball * uAudioFrequency * 0.2)) - sin(max(sin(abs((sin(uAudioFrequency * 0.3) * 0.5 + 0.5) * ceil(floor(PI * fract(-strength)) * 2.0 + 1.0))), -sin(uTime) * 0.5 + 0.5) * smoothstep(-0.3, 1.0, uAudioFrequency)), -0.01);
  // shapeIdea = abs(shapeIdea) - 0.03;
  // shapeIdea = mix(octahedron, polynomialSMin(ball, octahedron, gyroid), sin(uTime) * 0.5 + 0.5);

  float assembledGyroid = polynomialSMin(octahedron, max(octahedron, gyroid), sin(uTime * (uAudioFrequency * 0.1)) * 0.1 + 0.1);
  // assembledGyroid = stepUpDown(0.21, 0.55, assembledGyroid);

  // gyroid += gyroid1 * 0.08;
  // gyroid += gyroid2 * 0.03;
  // gyroid *= gyroid3 * 0.3;
  // gyroid += gyroid4 * 0.01;
  // gyroid += assembledGyroid * uAudioFrequency * 0.02;
  // gyroid *= 0.003 - displacement + sin(assembledGyroid + smoothstep(-0.8, 0.03, fract(uAudioFrequency * 0.1))) * 0.8;

  // float secondShape = polynomialSMin(ball, octahedron, -gyroid) - fract(displacement);

  // float octalPolyZ = polynomialSMin(octahedron - sin(position.z * 8.0 + uTime * 3.5 - uAudioFrequency * 0.03) * 0.2, -gyroid * displacement * 0.5, -0.3) / scale;

  // float octalPolyX = polynomialSMin(sdOctahedron(position1, displacement * 0.5) - sin(position.x * 8.0 + uTime * 3.5 - uAudioFrequency * 0.03) * 0.2, -sdGyroid(position3, displacement * 0.5), -0.1) / scale;

  // float firstShape = polynomialSMin(ball * 0.2 / torus, polynomialSMin(octahedron, max(octahedron, -gyroid), gyroid * uAudioFrequency * 0.1), octahedron);
  // firstShape = abs(firstShape) - 0.03;
  // float finalOctal = mix(octalPolyZ, octalPolyX, 1.0);

// Shapes used 

  // float finalIdea = max(shapeIdea, firstShape - assembledGyroid);
  // finalIdea = abs(finalIdea) - 0.01;

  // float morphedShaped = polynomialSMin(box, octahedron, polynomialSMin(sdSphere(position1, 0.5), 2.5 * sdGyroid(abs(sin(position1 + vec3(2.0))) * 34.5 * uTime, 5.2, 0.03, 0.08) / -34.5, -0.2));

  // float morphedShaped2 = polynomialSMin(torus, sdOctahedron(position2, smoothstep(-1.0, 3.0, 0.8)), sdSphere(abs(position2), 0.5));

  // float finalShape = mix(firstShape, morphedShaped, gyroid);
  // finalShape = normalize(finalShape);
  // finalIdea = mix(morphedShaped, morphedShaped2, sin(uTime) * 0.5 + 0.5);

  // return sdSphere(position, 0.5);

  // int i;
  // for (i = 0; i < 10; i++) {
  //   float random = random2D(vec2(i, 0.0));
  //   random = fract(random * 13.0);
  //   // float randomV = voroNoise(position, 0.1, 1.0);
  //   float progress = 1.0 - fract(uTime / 5.0 + random * 5.0);
  //   vec3 positionLoop = vec3(sin(random * 2.0 * PI), cos(random * 2.0 * PI), atan(random * 2.0 * PI));

  //   float goToCenter = sdSphere(copyPosition - positionLoop * progress, 0.02);
  //   // float morphLoop = sdBoxFrame();
  //   // goToCenter = opOnion(finalShape, morphedShaped);

  //   test = polynomialSMin(test, goToCenter, 0.2);
  // }

  // float mouseSphere = sdSphere(position - vec3(uMouse.xy * 2.0, 0.3), 0.1);

  float ground = position.y + .55;
  position.z -= uTime * 0.2;
  position *= 3.0;
  position.y += 1.0 - length(position.z) * 0.5 + 0.5;
  float groundWave = abs(dot(sin(position), cos(position.yzx))) * 0.1;
  ground += groundWave;
  // ground /= -(glitter(vec2(position1), uTime));

  return polynomialSMin(ground, assembledGyroid, 0.1);
}

vec3 calcNormal(in vec3 popsition) {
  const float epsilon = 0.00001;
  const vec2 h = vec2(epsilon, 0);
  return normalize(vec3(sdf(popsition + h.xyy) - sdf(popsition - h.xyy), sdf(popsition + h.yxy) - sdf(popsition - h.yxy), sdf(popsition + h.yyx) - sdf(popsition - h.yyx)));
}

void main() {

  // vec3 viewDirection = normalize(vPosition + cameraPosition);
  //   // vec3 color = uColor;
  // vec3 normal = normalize(vNormal);
  // if (!gl_FrontFacing)
  //   normal *= -1.0;

  //   // Strips
  // float stripes = mod((vPosition.y - uTime) * 21.0, 1.0);
  // stripes = pow(stripes, 3.0);

  // // Fresnel
  // float fresnel = dot(viewDirection, normal) + 1.0;
  // fresnel = pow(fresnel, 2.0);

  // // Falloff
  // float falloff = smoothstep(0.8, 0.0, fresnel);

  // // Holographic
  // float holographic = stripes * fresnel;
  // holographic += fresnel * 1.21;
  // holographic *= falloff;

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

    vec3 colorLoop = getColor(length(uv1) + i * 0.5 * uAudioFrequency * 0.5);

    // minimumDistance = min(minimumDistance, distanceToCenter);

    distanceToCenter = sin(distanceToCenter * 8.0 + max(uAudioFrequency * 0.001, uTime)) / 8.0;
    distanceToCenter = abs(distanceToCenter);

    distanceToCenter = pow(0.01 / distanceToCenter, 0.5);

    // distanceToCenter = smoothstep(0.2, 0.5, distanceToCenter);

    finalColor += colorLoop * distanceToCenter;
  }

  // Use new UV
  vec2 newUv = (vUv - vec2(0.5)) + vec2(0.5);
  // vec2 newUv = (gl_FragCoord - 0.5 * uResolution.xy) / uResolution.y;
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
  for (i = 0; i < 100; i++) {
    // The position along the ray
    vec3 position = raypos + t * ray;

    // float voroPosition = voroNoise(position, t,tMax);
    // pos.xy *= rotate(pos.xy, vec3(1.0), uTime);

    // Image movement with mouse (not actual rotation of plane)
    position.xy *= rot2d(t * 0.2 * uMouse.x);
    position.y = max(-0.9, position.y);
    position.y += sin(t * (uMouse.y - 0.5) * 0.02) * 0.21;

    // The Current distance to the scene
    float h = sdf(position);

    // The "march" of the ray
    t += h;
    // h = -(length(vec2(length(position.xz) - 1.0, position.y)) - 0.89);
    if (abs(h) < 0.0001 || t > tMax)
      break;

    // color = 1.0 - getColor(uTime * 0.01 + t * 0.5 + uAudioFrequency * 0.02);
    color = 1.5 - getColor(sin(abs(uTime * 0.001 * ceil(floor(PI * fract(t)) * 2.0 + 1.0))) - uAudioFrequency * 0.002);
    color = smoothstep(0.0, 1.0, color);

    // color *= 0.0;
    // color += glitter(vUv);

  }

  if (t < tMax) {
    vec3 position = camPos + t * ray;
    // position.x += sin(t * (uMouse.x - 0.5) * 0.5) * 0.89;
    // color = vec3(1.0);
    vec3 normal = calcNormal(position);
    vec3 rayReflect = reflect(ray, normal);
    vec3 lightDir = -normalize(position);

    float diff = dot(normal, lightDir) * 0.5 + 0.5;
    float centerDist = length(position);
    color = vec3(diff);

    float fresnel = pow(1.5 + dot(ray, normal), 3.0);
    color = vec3(fresnel);

    color = vec3(float(i) / 235.0);

    // color += glitter(vUv);
    // color -= getColor(position.xy * 8.0, 0.01) * 8.0;

    // color = 1.0 - palette(abs(sin(cos(uTime * 0.01 + t) * 0.5 + uAudioFrequency * 0.2) * vUv.x + uTime * 0.01));

    // color = 1.0 - getColor(color.y);

    // color *= finalColor;

    // color = pow(color, vec3(.4545));
    if (t < tMax) {

      if (centerDist > .001) {
      // color *= vec3(0, 1, 0);
        float shapeShadow = sdGyroid(-lightDir, 0.3, 0.02, 1.0);
        float shadowBlur = centerDist * 0.1;
        float shadow = smoothstep(-shadowBlur, shadowBlur, shapeShadow);
        color *= shadow * 0.9 + 0.1;

        position.z -= uTime * 0.2;
        color -= glitter(position.xy * 5.0, 0.01) * 8.0 * shadow;
        color *= 1.0 - -(shadow * getColor(centerDist * smoothstep(-0.3, 0.8, uAudioFrequency * 0.02)));
      }
    }
    // color = mix(1.0 - color, (1.0 - sphereColor + background * light * glow), fresnel);
    float centralLight = dot(newUv - 1.0, newUv);
    centralLight *= camPos.z - 1.0;

    float light = 0.03 / centralLight;
    vec3 lightColor = vec3(1.0, 0.8, 0.5);
    color += light * smoothstep(0.0, 0.5, camPos - 2.0) * lightColor;

    float glow = sdGyroid(normalize(camPos), 0.3, 0.03, 1.0);
    color += light * smoothstep(0.0, 0.03, glow) * lightColor;

    color *= 2.0 - centralLight * 0.8;
    color *= 1.5 - -(sin(abs(uTime * 0.2 * ceil(floor(PI * fract(uAudioFrequency * 0.2)) * 2.0 + 1.0))));
    color *= (1.0 - vec3(t / tMax));
  }

  color *= smoothstep(-0.8, 0.2, vUv.x);
  color *= smoothstep(-1.0, 0.3, vUv.x);
  color *= smoothstep(-0.8, 0.2, vUv.y);
  color *= smoothstep(-1.0, 0.3, vUv.y);

  // color = pow(color, vec3(1.0 / 2.2));

  gl_FragColor = vec4(color, 1.0);
    #include <tonemapping_fragment>
    #include <colorspace_fragment>
}