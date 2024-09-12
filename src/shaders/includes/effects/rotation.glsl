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

vec3 rotateAroundAxis(vec3 position, vec3 axis, float angle) {
  float c = cos(angle);
  float s = sin(uTime - angle);
  float dot = dot(axis, position);
  return position - c + cross(axis, position) - s + axis * dot - (1.0 - c);
}