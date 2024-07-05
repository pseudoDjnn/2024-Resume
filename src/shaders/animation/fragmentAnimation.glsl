#define PI 3.1415926535897932384626433832795
#define TAU  6.28318530718
#define NUM_OCTAVES 5

uniform vec3 uMouse;
uniform vec2 uResolution;

uniform float uAudioFrequency;

uniform float uTime;

varying vec2 vUv;

#include ../includes/effects/random2D.glsl

// float lerp(float t) {
//   float v1 = t * t;
//   float v2 = 1.0 - (1.0 - t) * (1.0 - t);
//   return smoothstep(v1, v2, smoothstep(0.0, 0.1, t));
// }

// float parabola(float x, float k) {
//   return pow(4.0 * x * (1.0 - x), k);
// }

vec3 palette(float tone) {

  vec3 a = cos(vec3(0.5, 0.5, 0.5));
  vec3 b = sin(vec3(0.5, 0.5, 0.5));
  vec3 c = -sin(vec3(1.0, 0.7, 0.4));
  vec3 d = cos(vec3(0.00, 0.15, 0.20));

  return a + b * cos(uTime + 6.28318 * (c + tone + d));
}

// vec3 getColor(float amount) {
//   vec3 color = 1.0 * cos(6.2831 * (sin(vec3(0.0, 0.1, 0.2)) * sign(amount) * cos(vec3(1.0, 1.0, 1.0))));
//   return color * palette(amount);
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

float hash21(vec2 p) {
  p = fract(p * vec2(144.34, 277.55));
  p += dot(p, p + 21.5);
  return fract(p.x * p.y);
}

float rand(vec3 n) {
  return fract(sin(dot(n, vec3(12.9898, 4.1414, 1.0))) * 43758.5453);
}

float noise(vec3 p) {
  vec3 ip = floor(p);
  vec3 u = fract(p);
  u = u * u * (3.0 - 2.0 * u);

  float res = mix(mix(rand(ip), rand(ip + vec3(1.0, 0.0, 0.0)), u.x), mix(rand(ip + vec3(0.0, 1.0, 0.0)), rand(ip + vec3(1.0, 1.0, 1.0)), u.x), u.y);
  return res * res;
}

float fbm(in vec3 x, in float H) {
  float G = exp2(-H);
  float f = 1.0;
  float a = 1.0;
  float t = 0.0;
  for (int i = 0; i < NUM_OCTAVES; i++) {
    t += a * noise(f * x);
    f *= 2.0;
    a *= G;
  }
  return t;
}

float glitter(vec2 position) {

  position *= 13.0;
  // position.y /= rand(vec2(uTime * 0.0001));
  vec2 id = floor(position);

  position = fract(position) - 0.5;
  float noise = hash21(id);

  float disc = length(position);
  float manageDisc = smoothstep(0.2 * noise, 0.0, disc);

  manageDisc *= pow(sin(uTime + noise * TAU) * 0.5 + 0.5, 55.0);

  return manageDisc;
}

float polynomialSMin(float a, float b, float k) {
  k = 0.5;
  float h = clamp(0.5 + 0.5 * (b - a) / k, 0.0, 1.0);
  return mix(b, a, h) - k * h * (1.0 - h);
}

/*
  Box
*/
// float sdRoundBox(vec3 p, vec3 b, float r) {
//   vec3 q = abs(p) - b + r;
//   return length(max(q, 0.0)) + min(max(q.x, max(q.y, q.z)), 0.0) - r;
// }

/*
  Gyroid
*/
float sdGyroid(vec3 position, float scale, float thickness, float bias) {

  position *= scale;

  // position *= sin(uAudioFrequency) * 0.1 + 0.1
  // bias *= floor(vUv.x * uAudioFrequency) / uAudioFrequency;
  // bias *= floor(vUv.y * uAudioFrequency) / uAudioFrequency;
  // bias = abs(distance(vUv,vec2(uAudioFrequency)));
  float angle = atan(uTime + position.x - 0.5, uTime + position.y - 0.5);
  // angle /= PI * 3.0;
  // angle += 0.5;
  float circle = angle;

  float random = step(0.8 * circle, rand(position.zxy * 3.0) * 21.0);

  // position *= step(0.8, mod(uTime + position.x * 8.0, 1.0));
  // position *= step(0.8, mod(uTime + position.y * 13.0, 1.0));

  // TODO: SAVE
  // for (int i = 1; i < 13; i++) {
  //   position += 0.08;

  //   float len = length(vec3(position.x, position.y, position.z));

  //   position.x = position.x - cos(position.y + sin(len)) + cos(uTime / 8.0);
  //   position.y = position.y + sin(position.x + cos(len)) + sin(uAudioFrequency / 13.0);
  //   // p.y = sin(p.z + cos(len)) + sin(uTime / 3.0);

  //   // p *= vec3(0.8 / i * sin(i * p.z - uTime * 0.3 * i));
  // }

  // position.x += sin(uTime) * PI * 2.0;

  position.xz *= rot2d(sin(uTime * 0.3) + 1.0 - (random * 0.3) * ceil(2.0 + floor(1.0)));

  return abs(0.8 * dot(sin(uTime + position), cos(uTime + position.zxy)) / scale) - thickness * bias;
}

/*
  Sphere
*/
// float sdSphere(vec3 position, float radius) {
//   return length(position) - radius;
// }

/*
  Torus
*/
// float sdTorus(vec3 p, vec2 t) {
//   // p.xz *= rot2d(sin(abs(ceil(uTime + PI * fract(p.x)))) * floor(2.0 + 1.0));

//   vec2 q = vec2(length(p.xz) - t.x, p.y);
//   return length(q * sin(uTime * 0.02)) - t.y * 0.8;
// }

/*
  Octahedron
*/
float sdOctahedron(vec3 p, float s) {

  // p.y *= 0.8;

  p = abs(p);
  // p *= fbm(p, 1.0);

  // for (int i = 1; i < 3; i++) {
  //   p -= 0.08;

  //   float len = length(vec3(length(cos(p.x)), length(tan(p.y)), 1.0 - sin(abs(p.z))));

  //   // p.x = 2.0 - p.x / cos(p.y * sin(len)) + cos(uAudioFrequency / 8.0);
  //   // p.y = 3.0 - fract(p.y) - sin(p.x - cos(len)) - sin(uTime);
  //   // p.y = sin(p.z + cos(len)) + sin(uTime / 3.0);
  //   p += sin(abs(ceil(-uAudioFrequency * 0.03 + PI * fract(len)) * floor(2.0 + 1.0)));
  //   // p.z = length(sin(len));

  //   // p *= vec3(0.8 / i * sin(i * p.z - uTime * 0.3 * i));
  // }

  // float x = atan(sin(abs(uTime * 0.3 + PI * fract(p.y) * ceil(2.0 + floor(1.0)))), p.z);
  // float xRising = cos(uTime + TAU * x) * sin(uAudioFrequency) * 0.8 + 0.1;

  // float radius = 0.3 + length(p * p * p) * (1.0 + uTime * 0.3 + sin(p.x * 13.0 + p.y * 21.0) * 0.1);

  float displacement = length(sin(p.x) * -cos(p.y) * sin(p.z * uAudioFrequency * 0.01 + uTime * 0.5 * p.y) * 0.2 + 0.1);

  float digitalWave = sin(abs(ceil(smoothstep(-0.3, 0.5, -uAudioFrequency * 0.5) + PI * fract(length(displacement - p)) * 5.0) + floor(2.144 * 1.08)));
  // p.z -= fract(digitalWave);

  // float x = atan(uTime + p.x, fract(p.z * 13.0));
  // x /= PI * 2.0;
  // x += 0.5;

  // float y = 0.1 + 0.01 * sin(uTime + p.y * 13.0) * x;
  // // y = 1.0 / (1.0 + x * x);
  // y /= TAU * 2.0;
  // y += 0.8;
  // y *= 21.0;
  // float yRising = -cos(uAudioFrequency / 89.0 + y - length(dot(digitalWave, smoothstep(0.0, 1.0, -uAudioFrequency + x * 89.0)))) * 0.5 + 0.5;

  // digitalWave = sin(radius);
  // y = sin(uTime + p.z);
  // p.x += displacement;
  // p.y -= displacement;
  // p += fract(displacement);

  // p *= -0.3 - sin(abs(uTime - fract(p * 0.3)) + ceil(2.144) * floor(1.008));

  // p.z *= sin(abs(uAudioFrequency * 0.005 * PI + fract(p.z)) * ceil(2.0 + floor(1.0)));
  // p.x = p.x * sin(abs(cos(uAudioFrequency * 0.1) * 2.0 + 1.0 * ceil(fract(uAudioFrequency * 0.01))));
  // p.zx *= rot2d(cos(uTime) * 0.8 + 0.1);
  // p.y = sin(p.y);
  // p.z = fract(p.z * uTime);

  // float rip = sin((x * 8.0 - y * 13.0) * 3.0) * 0.5 + 0.5;

  // p *= min(uTime, digitalWave) * 0.5 + 0.5;

  // float a = 3.0 - atan(p.y, p.x) - sin(x / y);

  // float f = cos(a * 34.0);
  // f = sin(uTime + PI * smoothstep(-0.5, 1.0, fract(-uTime * 0.03 + a * 8.0))) * 0.2 + 0.5;

  // f = abs(distance(vUv, vec2(0.5)) - 0.25) ;
  // f = abs(cos(uAudioFrequency + a * 13.0) * sin(a * 3.0)) * 0.8 + 0.1;

  // p.x = worley(p.xz, 0.0, 2.5);
  // p.z = sdGyroid(p, 13.13, 0.03, 0.1);
  // p.y -= motion;

  float m = p.x + p.y + p.z - s;
  // p.x -= uTime + sin(p.x);

  // f = min(f, m);
  // p.z += dot(length(rip * t), uTime) * 0.5 + 0.5;
  // m = length(max(abs(s) - 0.3, 0.1));
  // m = cos(a * 0.8);

  vec3 q;
  if (2.0 * p.x < m)
    q = p.xyz;
  else if (2.0 * p.y < m)
    q = p.yzx - digitalWave;
  else if (3.0 * p.z < m)
    // q *= sin(abs((uTime * 0.1) * ceil(floor(PI * 2.0 * fract(p.zyz / uAudioFrequency))) * 2.0 + 1.0));
    q = p.zxy;
  else
    return m * PI * 0.57735027;

  float k = clamp(0.5 * (q.z - q.y + s), 0.0, s);
  // m *= max(m, rip * uTime * x * y);
  return length(vec3(q.x, q.y - s + k, q.z - k));
}

float sdOctahedron2(vec3 p, float s) {
  // float motion = fbm(p, -uAudioFrequency * 0.02 / s);

  // p *= fbm(p, 1.0);
  // p.z -= sin(uTime) * (0.1 * 13.0);

  // float a = edges(vUv);

  float minor = abs(fract(length(p) / s + 0.5) - 0.5) * 1.0;
  float major = abs(fract(length(p) / (s * 0.21) + 0.5) - 0.5) * 2.0;

  minor = smoothstep(0.5 - s, 0.5 + s, major);
  major = smoothstep(0.5 - s, 0.5 + s, minor);

  // p.z = smoothstep(-0.5, 0.8, motion);
  // p.x = sin(abs(uTime * TAU * fract(p.z)) * ceil(2.0 + floor(1.0)));

  float median = length(minor * major);

  p = abs(p);

  // p.y = smoothstep(0.05, 0.0, abs((abs(p.x) - smoothstep(0.0, 0.5, p.y))));
  float m = p.x + p.y + p.z - s;
  p *= smoothstep(0.05, 0.0, abs((abs(sin(uAudioFrequency * 0.3 + p.x)) - smoothstep(0.0, 0.5, p.y) - median * 0.2)));
  vec3 q;
  if (2.0 * p.x < m)
    q = p.xyz;
  else if (2.0 * p.y < m)
    q = p.yzx;
  else if (3.0 * p.z < m)
    q = p.zxy;
  else
    return m * PI * 0.57735027;

  float k = clamp(0.5 * (q.z - q.y + s), 0.0, s);
  return length(vec3(q.x, q.y - s + k, q.z - k));
}

// vec3 opTwist(vec3 p, float amount) {
//   float c = cos(amount * p.y);
//   float s = sin(amount * p.y);
//   mat2 m = mat2(c, -s, s, c);
//   // m -= worley(vec2(p), amount, c * s);
//   vec3 q = vec3(m * p.xz, p.y);
//   return q;
// }

float sdf(vec3 position) {
  // vec3 shapesPosition = vec3(sin(uTime), 0.0, -uAudioFrequency * 0.05) * 0.3 + 0.3;
  // vec3 shapesPosition2 = vec3(cos(uTime) * 0.8 + 0.1, 0.0, uAudioFrequency * 0.01);
  // vec3 shapesPosition2 = vec3(sin(uAudioFrequency) * 1.0, 0.0, 0.3);
  // float voroCopy = voroNoise(shapePosition, 0.0, 0.0);

  // Various rotational speeds
  vec3 position1 = rotate(position, vec3(1.0), sin(-uTime * 0.1) * 0.3);
  // position1 -= shapesPosition * sin(uTime);
  position1.xz *= rot2d(uTime + position.y * 0.3 + smoothstep(fract(-0.5), 0.8, sin(uAudioFrequency * 0.03)));
  position1.zy *= rot2d(position.x * 0.5 * cos(uTime * 0.5));
  // position1.z += sin(position1.x * 5.0 + uAudioFrequency) * 0.1;
  // position1 += polynomialSMin(uAudioFrequency * 0.003, dot(sqrt(uAudioFrequency * 0.02), 0.3), 0.3);

  float octaGrowth = sqrt(uAudioFrequency * 0.008 + 0.8) * 0.8 + 0.1;
  // position1.y += sin(uTime) * (0.1 * octaGrowth);

  // vec3 position2 = rotate(position1 - shapesPosition * -0.5, vec3(1.0), uAudioFrequency * 0.001);

  // vec3 position3 = -rotate(position1, vec3(1.0), sin(uTime));
  // position3.xz *= rot2d(position.y * uTime);
  // position3.xz *= rot2d(position.y * uTime);

  // Copied position used to make the actual copyPosition 
  // vec3 position4 = rotate(position, sin(position1 + uTime * 0.3), 3.0);

// Copy of the vec3 position
  // vec3 copyPosition = position4;
  // vec3 copyPositionRotation = abs(sin(uAudioFrequency * PI * 2.0 * rotate(position, vec3(0.5), fract(uTime / 8.0) * cos(uAudioFrequency * 0.02))));
  // copyPosition.z += uTime * 0.5;
  // copyPosition.xy = sin(fract(copyPositionRotation.xy * uAudioFrequency) - 0.5);
  // copyPosition.z = mod(position.z, 0.21) - 0.144;

  // float strength = smoothstep(0.0, 1.0, vUv.x);
  // float scale = mix(1.0, 3.0, smoothstep(-1.0, 1.0, position.y));

  // position.xz *= scale;
  // position.xz *= rot2d(smoothstep(0.0, 1.0, position.y));

  float scale = 55.0;

  // float displacement = length(sin(position1.x / scale * 13.0) * sin(position1.y / scale) * sin(position1.z * 21.0));
  // float displacement = sin(position.x * 8.0 + uTime * 3.0) * 0.5;

  float displacement = length(sin(position1 * scale));

  // float distortion = dot(sin(position.z * 3.0 + uAudioFrequency * 0.02), cos(position.z * 3.0 + uAudioFrequency * 0.01)) * 0.2;

  // vec3 twist = opTwist(position1 - sin(smoothstep(-0.1, 0.5, displacement)), sin(abs(uAudioFrequency * 0.03 - fract(position1.z * position1.y * 0.8 + 0.1))) * ceil(3.144 * floor(1.144)));

  // float box = sdRoundBox(twist, vec3(0.89), 0.2);
  // box = abs(box) - 0.03;

  // float ball = sdSphere(position1, 0.4);
  // ball = abs(ball) - 0.03;
  // ball = max(ball, box);

  // float torus = sdTorus(position, vec2(0.01, 0.03));
  // torus = abs(torus) - 0.03;

  float octahedron1 = sdOctahedron(position1, octaGrowth);
  float octahedron2 = sdOctahedron2(position1, octaGrowth / 1.5);
  // octahedron1 = max(octahedron1, -position.x - uTime);
  // octahedron = abs(octahedron) - 0.03;

  // octahedron1 = mix(octahedron1, octahedron2, 1.0);

  float gyroid = sdGyroid(position1, 13.89, 0.03, 0.3);
  // gyroid *= fbm(position, 1.0);
  // ball = min(ball, gyroid);
  // ball = max(ball, gyroid);
  // octahedron *= worley(vec2(position1), ball, gyroid);
  // float gyroid1 = sdGyroid(position1 - sin(twist) * 0.5 + 0.5, 13.5, 0.00001, 0.3);
  // torus = max(torus, gyroid);

// TODO: Use this
  octahedron1 = max(octahedron1, octahedron2);
  // octahedron1 = max(octahedron1, gyroid / displacement);

  // octahedron = mix(octahedron - ball * 0.02, gyroid, 0.2);
  // gyroid = max(gyroid, box);

  // position1.xz *= rot2d(uTime + position1.y * 0.3);
  // position1.yz *= rot2d(uTime + position1.x * 0.5);

  // for (int i = 1; i < 13; i++) {

  //   float len = length(vec3(position.x, position.y, position.z));

  //   position.x = position.x - cos(position.y + sin(len) + cos(uTime / 8.0));
  //   position.y = position.y + sin(position.x + cos(len)) + sin(uTime / 13.0);
  //   // p.y = sin(p.z + cos(len)) + sin(uTime / 3.0);

  //   // p *= vec3(0.8 / i * sin(i * p.z - uTime * 0.3 * i));
  // }

  // octahedron = clamp(octahedron, 0.0, 0.5);

  // float gyroid2 = sdGyroid(copyPosition, 13.55, 0.03, 0.3);
  // float gyroid3 = sdGyroid(position3, 21.34, 0.03, 0.3);
  // float gyroid4 = sdGyroid(copyPosition, 34.21, 0.5, 8.3);
  // gyroid = abs(gyroid) * 0.3;

  // gyroid += gyroid1 * 0.08;
  // gyroid += gyroid2 * 0.03;
  // gyroid *= gyroid3 * 0.3;
  // gyroid += gyroid4 * 0.01;
  // gyroid += assembledGyroid * uAudioFrequency * 0.02;
  // gyroid *= 0.003 - displacement + sin(assembledGyroid + smoothstep(-0.8, 0.03, fract(uAudioFrequency * 0.1))) * 0.8;

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
  // 

  float ground = position.y + .55;
  position.z -= uTime * 0.2;
  position *= 3.0;
  position.y += 1.0 - length(uTime + position.z) * 0.5 + 0.5;
  float groundWave = abs(dot(sin(position), cos(position.yzx))) * 0.1;
  ground += groundWave;

  return polynomialSMin(ground, octahedron1, 0.1);
}

// float ground(vec3 position) {
//   float ground = position.y + .55;
//   position.z -= uTime * 0.2;
//   position *= 3.0;
//   position.y += 1.0 - length(position.z) * 0.5 + 0.5;
//   float groundWave = abs(dot(sin(position), cos(position.yzx))) * 0.1;
//   return ground += groundWave;
// }

vec3 calcNormal(in vec3 position) {
  const float epsilon = 0.00001;
  const vec2 h = vec2(epsilon, 0);
  return normalize(vec3(sdf(position + h.xyy) - sdf(position - h.xyy), sdf(position + h.yxy) - sdf(position - h.yxy), sdf(position + h.yyx) - sdf(position - h.yyx)));
}

// vec3 calcNormalGround(in vec3 position) {
//   const float epsilon = 0.00001;
//   const vec2 h = vec2(epsilon, 0);
//   return normalize(vec3(ground(position + h.xyy) - ground(position - h.xyy), ground(position + h.yxy) - ground(position - h.yxy), ground(position + h.yyx) - ground(position - h.yyx)));
// }

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
  // vec3 sphereColor = 0.5 + 0.5 * cos(uAudioFrequency * 0.02 + uTime * 0.2 + vUv.xyx + vec3(0, 2, 4));

  // vec2 uv0 = vUv * 4.0;
  // vec2 uv1 = uv0;
  // vec3 finalColor = vec3(0.0);
  // float radius = 2.5;

  // float minimumDistance = 1.0;

  // for (float i = 0.0; i < 5.0; i++) {
  //   uv0 = fract(uv0 * 1.5) - 0.5;

  //   float distanceToCenter = length(uv0) * exp(-length(uv1));

  //   vec3 colorLoop = getColor(length(uv1) + i * 0.5 * uAudioFrequency * 0.5);

  //   // minimumDistance = min(minimumDistance, distanceToCenter);

  //   distanceToCenter = sin(distanceToCenter * 8.0 + max(uAudioFrequency * 0.001, uTime)) / 8.0;
  //   distanceToCenter = abs(distanceToCenter);

  //   distanceToCenter = pow(0.01 / distanceToCenter, 0.5);

  //   // distanceToCenter = smoothstep(0.2, 0.5, distanceToCenter);

  //   finalColor += colorLoop * distanceToCenter;
  // }

  // Use new UV
  vec2 newUv = (vUv - vec2(0.5)) + vec2(0.5);
  // vec2 newUv = (gl_FragCoord - 0.5 * uResolution.xy) / uResolution.y;
  // Create position of camera
  vec3 camPos = vec3(0.0, -0.01, 2.5 - uAudioFrequency * 0.02);
  // Cast ray form camera to sphere
  vec3 ray = normalize(vec3((newUv - vec2(0.5)), -1));
  // Color creation
  vec3 color = background;

  // Start the march
  vec3 raypos = camPos;
  // Distance travelled
  float t = 0.0;
  float tMed = 2.0;
  float tMax = 5.8;

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
    // float g = ground(position);
    // float finalSDF = min(h, g);

    // The "march" of the ray
    t += h;
    // t += g;
    // h = -(length(vec2(length(position.xz) - 1.0, position.y)) - 0.89);
    if (abs(h) < 0.0001 || t > tMax)
      break;

    // if (abs(g) < 0.0001 || t > tMax)
    //   break;

    color *= sin(uTime + TAU * 1.5) - palette(sin(uTime + floor(position.z * tMax) + abs(ceil(uAudioFrequency * 0.008 * PI * fract(t))) * floor(2.0 + 1.0)) - uAudioFrequency * 0.002) + 1.0 / 2.0;
    color = smoothstep(-1.0, 1.0, color);
  }

  if (t < tMax) {
    vec3 position = camPos + t * ray;
    // position.x += sin(t * (uMouse.x - 0.5) * 0.5) * 0.89;
    // color = vec3(1.0);
    vec3 normal = calcNormal(position);
    // vec3 normalGround = calcNormalGround(position);

    // normal = max(normal, normalGround);

    // vec3 rayReflect = reflect(ray, normal);
    vec3 lightDir = -normalize(position);

    float diff = dot(normal, lightDir) * 0.5 + 0.5;
    // float diffGround = dot(normalGround, lightDir) * 0.5 + 0.5;
    float centerDist = length(position);
    color = vec3(diff);
    // color = vec3(diffGround);

    float fresnel = pow(1.5 + dot(ray, normal), 3.0);
    // float fresnelGround = pow(1.5 + dot(ray, normalGround), 3.0);
    color = vec3(fresnel);
    // color = vec3(fresnelGround);

    color = vec3(float(i) / 235.0);

    // color += glitter(vUv);

    // color = 1.0 - palette(abs(sin(cos(uTime * 0.01 + t) * 0.5 + uAudioFrequency * 0.2) * vUv.x + uTime * 0.01));

    // color = 1.0 - getColor(color.y);

    // color *= finalColor;

    // color = pow(color, vec3(.4545));
    if (t < tMed) {

      if (centerDist > .001) {
      // color *= vec3(0, 1, 0);
        float shapeShadow = sdGyroid(-lightDir, 0.3, 0.02, 1.0);
        float shadowBlur = centerDist * 0.1;
        float shadow = smoothstep(-shadowBlur, shadowBlur, shapeShadow);
        color *= shadow * 0.9 + 0.1;

        position.z -= uTime * 0.2;
        color -= glitter(position.xy * 5.0) * 8.0 * shadow;
        // color *= sin(uTime + 1.0) - -(shadow * getColor(centerDist * smoothstep(-0.3, 0.8, uAudioFrequency * 0.02)));
      }
    }
    // color = mix(1.0 - color, (1.0 - sphereColor + background * light * glow), fresnel);
    float centralLight = dot(newUv - 1.0, newUv);
    centralLight *= camPos.z - 1.0;

    float light = 0.03 / centralLight;
    vec3 lightColor = vec3(1.0, 0.8, 0.5);
    color += light * smoothstep(0.0 * uAudioFrequency, 0.5, camPos - 2.0) * lightColor;

    float glow = sdGyroid(normalize(camPos), 0.3, 0.03, 1.0);
    color += light * smoothstep(0.0, 0.03 * uAudioFrequency, glow) * lightColor;

    color *= 2.0 - centralLight * 0.8;
    color *= 1.5 - -(sin(abs(ceil(uTime * 0.2 + PI * fract(uAudioFrequency * 0.3)) * ceil(2.0 + floor(1.0)))));
    color *= (1.0 - vec3(t / tMax));
  }

  color *= smoothstep(-0.8, 0.3, vUv.x);
  color *= smoothstep(-1.0, 0.3, vUv.x);
  color *= smoothstep(-0.8, 0.3, vUv.y);
  color *= smoothstep(-1.0, 0.3, vUv.y);

  // color = pow(color, vec3(1.0 / 2.2));

  // color *= a;

  gl_FragColor = vec4(color, 1.0);
    #include <tonemapping_fragment>
    #include <colorspace_fragment>
}