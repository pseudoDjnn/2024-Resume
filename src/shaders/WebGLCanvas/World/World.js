import * as THREE from 'three'
import WebGLCanvas from "../WebGLCanvas";
import Sizes from '../Utils/Sizes';
import Environment from './Environment';
import vertexParticleShader from '../../particles/vertexParticles.glsl'
import fragmentParticleShader from '../../particles/fragmentParticles.glsl'

export default class World {
  constructor() {
    this.webglCanvas = new WebGLCanvas()
    this.sizes - new Sizes()
    this.scene = this.webglCanvas.scene

    // console.log(this.scene)

    // Test mesh
    const testMesh = new THREE.Mesh(
      new THREE.BoxGeometry(1, 1, 1),
      new THREE.MeshBasicMaterial()
    )
    // this.scene.add(testMesh)
    // console.log(testMesh)

    /**
     * Particle animation
     */

    const parameters = {
      count: 144
    }

    let color = {}
    let particles = null

    const generateParticles = (position, radius) => {

      particles = {}


      // Geometry
      particles.geometry = new THREE.IcosahedronGeometry(5, 34)


      // Material
      particles.material = new THREE.ShaderMaterial({
        // transparent: true,
        // vertexColors: true,
        vertexShader: vertexParticleShader,
        fragmentShader: fragmentParticleShader,
        uniforms: {
          uSize: new THREE.Uniform(0.4), //* renderer.getPixelRatio(8),
          // uTime: new THREE.Uniform(0),
          uResolution: new THREE.Uniform(new THREE.Vector2(this.width * this.pixelRatio, this.height * this.pixelRatio)),
          uColorAlpha: new THREE.Uniform(new THREE.Color(color.colorAlpha)),
          uColorBeta: new THREE.Uniform(new THREE.Color(color.colorBeta)),
        },
        // blending: THREE.AdditiveBlending,
        // depthWrite: false,
      })

      // Points
      particles.points = new THREE.Points(particles.geometry, particles.material)
      // particles.points.frustumCulled = false
      // particles.points.position.copy(position).multiplyScalar(5)
      // particles.points.position.x = 5
      // particles.points.position.y = 3
      // particles.points.position.z = 8

      this.scene.add(particles.points)
      // console.log(particles.points)

    }


    generateParticles(
      new THREE.Vector3(),        // Position (Spherical)
      144                          // Radius
    )

    // Setup 
    this.environment = new Environment()
  }
}