import * as THREE from 'three'
import WebGLCanvas from '../WebGLCanvas'

import vertexParticleShader from '../../shaders/particles/vertexParticles.glsl'
import fragmentParticleShader from '../../shaders/particles/fragmentParticles.glsl'

export default class Particles {
  constructor() {
    this.webglCanvas = new WebGLCanvas()
    this.scene = this.webglCanvas.scene
    this.time = this.webglCanvas.time

    // console.log('this is working')

    /**
     * Particle animation
     */

    this.parameters = {
      count: 13
    }

    this.color = {}
    this.particles = null

    const generateParticles = (position, radius) => {

      this.particles = {}

      // Geometry
      this.particles.geometry = new THREE.IcosahedronGeometry(5, 21)


      // Material
      this.particles.material = new THREE.ShaderMaterial({
        transparent: true,
        vertexColors: true,
        vertexShader: vertexParticleShader,
        fragmentShader: fragmentParticleShader,
        uniforms: {
          uSize: new THREE.Uniform(0.4), // * this.getPixelRatio(8),
          uTime: new THREE.Uniform(0),
          uResolution: new THREE.Uniform(new THREE.Vector2(this.width * this.pixelRatio, this.height * this.pixelRatio)),
          uColorAlpha: new THREE.Uniform(new THREE.Color(this.color.colorAlpha)),
          uColorBeta: new THREE.Uniform(new THREE.Color(this.color.colorBeta)),
        },
        blending: THREE.AdditiveBlending,
        depthWrite: false,
      })

      // Points
      this.particles.points = new THREE.Points(this.particles.geometry, this.particles.material)
      this.particles.points.frustumCulled = false
      this.particles.points.position.copy(position).multiplyScalar(3)
      // this.particles.points.position.x = 5
      // this.particles.points.position.y = 3
      // this.particles.points.position.z = 8

      this.scene.add(this.particles.points)
      // console.log(particles.points)

    }


    generateParticles(
      new THREE.Vector3(),        // Position (Spherical)
      55                          // Radius
    )
  }

  update() {
    this.particles.material.uniforms.uTime.value = (this.time.elapsed - 0.5) * 0.00000034
    // console.log(this.particles)
  }
}