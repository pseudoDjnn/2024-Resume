import * as THREE from 'three'
import WebGLCanvas from "../WebGLCanvas";

export default class Environment {
  constructor() {
    this.webglCanvas = new WebGLCanvas()
    this.scene = this.webglCanvas.scene

    // console.log(this.scene)


    // Use this for Debugging eventually

  }

}