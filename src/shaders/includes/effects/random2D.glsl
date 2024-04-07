float random2D(vec2 st) {
  return -1.0 + 2.0 * fract(sin(dot(st.xy, vec2(12.9898, 78.233))) * 43758.5453123);
}