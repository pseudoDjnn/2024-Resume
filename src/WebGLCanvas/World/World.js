import WebGLCanvas from "../WebGLCanvas";
import Environment from './Environment';
import Particles from './Particles';
import Animation from "./Animation";


export default class World {
  constructor() {
    this.webglCanvas = new WebGLCanvas()
    this.scene = this.webglCanvas.scene
    this.time = this.webglCanvas.time

    // console.log(this.scene)

    // Setup 
    this.environment = new Environment()
    this.particles = new Particles()
    this.animation = new Animation()
  }


  update() {
    // console.log('this works')

    if (this.particles) {
      this.particles.update()
    }
  }
}