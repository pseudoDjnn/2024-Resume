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
      count: 2584
    }

    this.color = {}
    this.particles = null

    const generateParticles = (position, radius) => {

      this.particles = {}

      // Geometry
      this.particles.geometry = new THREE.IcosahedronGeometry(5, 3)
      this.particles.geometry.setIndex(null)
      this.particles.geometry.deleteAttribute('normal')

      this.color.colorAlpha = '#CEB180'
      this.color.colorBeta = '#4D516D'
      this.particles.positions = new Float32Array(this.parameters.count * 3)
      this.particles.randomness = new Float32Array(this.parameters.count)

      /**
       * Memoized fibbonacci sequence instead of using Math.random()
       */
      this.particles.fibbonacci = (i, count = {}) => {
        this.i3 = i * 3
        if (i in count) return count[i];
        if (i < 2) return 1;

        // Spherical body
        this.spherical = new THREE.Spherical(
          radius * (0.21 + Math.random() * 0.13),
          Math.random() * Math.PI,
          Math.random() * Math.PI * 2,
        )
        this.sphericalPointPosition = new THREE.Vector3()
        this.sphericalPointPosition.setFromSpherical(this.spherical)

        count[i] = this.particles.fibbonacci(i - 1, count) + this.particles.fibbonacci(i - 2, count)

        // XYZ positioning
        this.particles.positions[this.i3] = (this.sphericalPointPosition.x)
        this.particles.positions[this.i3 + 1] = (this.sphericalPointPosition.y)
        this.particles.positions[this.i3 + 2] = (this.sphericalPointPosition.z)

        // Randomness
        const randomIndex = Math.floor(this.particles.positions[this.i3] * Math.random()) * 3
        // console.log(randomIndex)

        this.particles.randomness[this.i3] = this.particles.positions[this.i3] + randomIndex * 2 - 1
        this.particles.randomness[this.i3 + 1] = this.particles.positions[this.i3 + 1] / 0xff + (randomIndex * 2 - 1) / 0xff + this.particles.randomness[this.i3 + 2] / 0xff
        this.particles.randomness[this.i3 + 2] = this.particles.positions[this.i3 + 2] + randomIndex * 2 - 1

        return count[this.i3 * 3]
      }


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

      // this.particles.geometry.setAttribute('position', new THREE.BufferAttribute(this.particles.positions, 3))
      // this.particles.geometry.setAttribute('aRandomness', new THREE.BufferAttribute(this.particles.randomness, 3))

      // Points
      this.particles.points = new THREE.Points(this.particles.geometry, this.particles.material)
      this.particles.points.frustumCulled = false
      this.particles.points.position.copy(position).multiplyScalar(5)
      // this.particles.points.position.x = 3
      // this.particles.points.position.y = -3
      // this.particles.points.position.z = 8

      this.particles.fibbonacci(377)
      this.scene.add(this.particles.points)
      // console.log(particles.points)

    }


    generateParticles(
      new THREE.Vector3(),        // Position (Spherical)
      144                          // Radius
    )
  }

  update() {
    this.particles.material.uniforms.uTime.value = (-this.time.elapsed - 0.5) * 0.0000000034
    // console.log(this.particles)
  }
}