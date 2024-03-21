uniform float uSize;
uniform float uTime;
uniform vec2 uResolution;

attribute vec3 aRandomness;

varying vec3 vColor;
varying vec2 vUv;

void main() {
  vec4 modelPosition = modelMatrix * vec4(position, 1.0);

   // Rotation
  float angle = atan(modelPosition.x, modelPosition.z);
  float distanceToCenter = length(modelPosition.xz);
  float angleOffset = (1.0 / distanceToCenter) * uTime * 1.55;
  angle += angleOffset;
  modelPosition.x = cos(angle) * distanceToCenter;
  modelPosition.z = sin(angle) * distanceToCenter;

  // Randomness
  modelPosition.xyz *= aRandomness;

  vec4 viewPosition = viewMatrix * modelPosition;
  vec4 projectedPosition = projectionMatrix * viewPosition;
  gl_Position = projectedPosition;

// Final Position
  gl_PointSize = uSize * uResolution.y;
  gl_PointSize *= (1.0 / -viewPosition.z);

  // Varying
  vColor = color;
  vUv = uv;
}
