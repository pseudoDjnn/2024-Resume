uniform float uSize;
uniform float uTime;
uniform vec2 uResolution;
uniform vec3 uColorAlpha;
uniform vec3 uColorBeta;

attribute vec3 aRandomness;

varying vec3 vColor;
varying vec2 vUv;

#include ../includes/effects/simplexNoise3D.glsl

void main() {
  vec4 modelPosition = modelMatrix * vec4(position, 1.0);

  float noise = simplexNoise3d(position);
  noise = smoothstep(-1.0, 1.0, noise);

   // Rotation
  float angle = atan(modelPosition.x, modelPosition.z);
  float distanceToCenter = length(modelPosition.xz);
  float angleOffset = (1.0 / distanceToCenter) * uTime * 1.55;
  angle += angleOffset;
  modelPosition.x = cos(angle) * distanceToCenter;
  modelPosition.z = sin(angle) * distanceToCenter;

  // Randomness
  modelPosition.xyz *= aRandomness * 13.0;

  vec4 viewPosition = viewMatrix * modelPosition;
  vec4 projectedPosition = projectionMatrix * viewPosition;
  gl_Position = projectedPosition;

// Final Position
  gl_PointSize = uSize * uResolution.y;
  gl_PointSize *= (0.3 / -viewPosition.z);

  // Varying
  vColor = mix(uColorAlpha, uColorBeta, noise);
  vUv = uv;
}
