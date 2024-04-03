import WebGLCanvas from "../WebGLCanvas";
import Environment from './Environment';
import Particles from './Particles';
import Animation from "./Animation";
import Audio from "./Audio";


export default class World {
  constructor() {
    // console.log(this.scene)

    this.webglCanvas = new WebGLCanvas()
    this.scene = this.webglCanvas.scene
    this.time = this.webglCanvas.time
    this.audio = new Audio()


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

    if (this.animation) {
      this.animation.update()
    }
  }
}