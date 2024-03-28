import * as THREE from 'three'
import { OrbitControls } from 'three/examples/jsm/controls/OrbitControls.js'
import WebGLCanvas from "./WebGLCanvas";

export default class Camera {
  constructor() {

    this.webglCanvas = new WebGLCanvas()
    this.sizes = this.webglCanvas.sizes
    this.scene = this.webglCanvas.scene
    this.canvas = this.webglCanvas.canvas

    this.setInstance()
    this.setOrbitControl()
    // console.log('my camera', this)
  }

  setInstance() {
    this.instance = new THREE.PerspectiveCamera(75, this.sizes.width / this.sizes.height, 0.1, 100)
    this.instance.position.set(8.5, 5, 13)
    this.scene.add(this.instance)
  }

  setOrbitControl() {
    this.controls = new OrbitControls(this.instance, this.canvas)
    this.controls.enableDamping = true
  }

  resize() {

    this.instance.aspect = this.sizes.width / this.sizes.height
    this.instance.updateProjectionMatrix()

    // console.log('this is resizing the camera')
  }

  update() {
    this.controls.update()
  }
}