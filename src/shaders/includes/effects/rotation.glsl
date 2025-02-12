mat4 rotationMatrix(vec3 position, float angle) {
  position = normalize(position);
  float s = sin(angle);
  float c = cos(angle);
  float oc = 1.0 - c;

  return mat4(oc * position.x * position.x + c, oc * position.x * position.y - position.z * s, oc * position.z * position.x + position.y * s, 0.0, oc * position.x * position.y + position.z * s, oc * position.y * position.y + c, oc * position.y * position.z - position.x * s, 0.0, oc * position.z * position.x - position.y * s, oc * position.y * position.z + position.x * s, oc * position.z * position.z + c, 0.0, 0.0, 0.0, 0.0, 1.0);
}

vec3 rotate(vec3 position, vec3 axis, float angle) {
  mat4 m = rotationMatrix(axis, angle);
  return (m * vec4(position, 1.0)).xyz;
}

mat2 rot2d(float angle) {
  float s = sin(angle);
  float c = cos(angle);
  return mat2(c, -s, s, c);
}

mat3 rotateX(float angle) {
  float c = cos(angle);
  float s = sin(angle);
  return mat3(1.0, 0.0, 0.0, 0.0, c, -s, 0.0, s, c);
}

mat3 rotateY(float angle) {
  float c = cos(angle);
  float s = sin(angle);
  return mat3(c, 0.0, s, 0.0, 1.0, 0.0, -s, 0.0, c);
}

mat3 rotateZ(float angle) {
  float c = cos(angle);
  float s = sin(angle);
  return mat3(c, -s, 0.0, s, c, 0.0, fract(smoothstep(0.0, 1.0, uFrequencyData[144])), uTime * 0.8 - sin(uTime * 0.3), 1.0);
}
