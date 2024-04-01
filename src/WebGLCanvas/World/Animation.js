import * as THREE from 'three'
import WebGLCanvas from '../WebGLCanvas'

import animationVertexShader from '../../shaders/animation/vertexAnimation.glsl'
import animationFragmentShader from '../../shaders/animation/fragmentAnimation.glsl'

export default class Animation {
  constructor() {

    this.webglCanvas = new WebGLCanvas()
    this.scene = this.webglCanvas.scene
    this.time = this.webglCanvas.time


    // console.log('this is for the animation')

    this.geometry = new THREE.IcosahedronGeometry(13, 2)
    this.geometry.setIndex(null)
    this.geometry.deleteAttribute('normal')

    this.material = new THREE.ShaderMaterial({
      vertexShader: animationVertexShader,
      fragmentShader: animationFragmentShader,
    })

    this.mesh = new THREE.Mesh(this.geometry, this.material)
    this.scene.add(this.mesh)
  }
}