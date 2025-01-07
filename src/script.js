import WebGLCanvas from "./WebGLCanvas/WebGLCanvas";

const webglCanvas = new WebGLCanvas(document.querySelector('canvas.webgl'))

// Wait for the DOM to load and simulate a loading process
document.addEventListener("DOMContentLoaded", () => {
  // Simulate a loading process (adjust the timeout as needed)
  setTimeout(() => {
    const loader = document.getElementById("loading-screen");
    const canvas = document.getElementById("mainCanvas");

    // Fade out the loader
    loader.style.opacity = "0";
    loader.style.transition = "opacity 1.5s ease";
    loader.addEventListener("transitionend", () => {
      loader.style.display = "none"; // Completely remove the loader
    });

    // Fade in the canvas
    canvas.classList.remove("hidden");
    canvas.classList.add("fade-in");
  }, 3000); // Simulate a 3-second loading time
});




// import * as THREE from 'three'
// import { OrbitControls } from 'three/examples/jsm/controls/OrbitControls.js'
// import GUI from 'lil-gui'
// // impot { GLTFLoader } from 'three/examples/jsm/loaders/GLTFLoader.js'
// import vertexShaderAnimation from './shaders/animation/vertexAnimation.glsl'
// import fragmentShaderAnimation from './shaders/animation/fragmentAnimation.glsl'
// import vertexShaderParticles from './shaders/particles/vertexParticles.glsl'
// import fragmentShaderParticles from './shaders/particles/fragmentParticles.glsl'



// /**
//  * Base
//  */
// // Debug
// // const gui = new GUI({ width: 340 })

// // Canvas
// const canvas = document.querySelector('canvas.webgl')

// // Scene
// const scene = new THREE.Scene()

// // Axes Helper
// // const axesHelper = new THREE.AxesHelper(5);
// // scene.add(axesHelper);


// /**
//  * Sizes
// */
// const sizes = {
//     width: window.innerWidth,
//     height: window.innerHeight,
//     pixelRatio: Math.min(window.devicePixelRatio, 2)
// }
// sizes.resolution = new THREE.Vector2(sizes.width, sizes.height)

// window.addEventListener('resize', () => {
//     // Update sizes
//     sizes.width = window.innerWidth
//     sizes.height = window.innerHeight
//     sizes.pixelRatio = Math.min(window.devicePixelRatio, 2)
//     sizes.resolution.set(sizes.width, sizes.height)

//     // Update materials
//     materialAnimation.uniforms.uResolution.value.set(sizes.width * sizes.pixelRatio, sizes.height * sizes.pixelRatio)

//     // Update camera
//     camera.aspect = sizes.width / sizes.height
//     camera.updateProjectionMatrix()

//     // Update renderer
//     renderer.setSize(sizes.width, sizes.height)
//     renderer.setPixelRatio(sizes.pixelRatio)
// })


// /**
//  * Textures and loaders
//  */
// // const gltfLoader = new GLTFLoader()
// const textureLoader = new THREE.TextureLoader()
// // const particleTexture = textureLoader.load('/textures/gradients/5.jpg')
// // particleTexture.colorSpace = THREE.SRGBColorSpace
// // particleTexture.magFilter = THREE.NearestFilter

// /**
//  * Particle parameters
//  */
// const parameters = {
//     count: 144,
// }

// let color = {}
// let particles = null

// const generateParticles = (position, radius) => {

//     particles = {}

//     particles.maxCount = 0

//     particles.geometry = new THREE.IcosahedronGeometry(5, 34)
//     particles.geometry.setIndex(null)
//     particles.geometry.deleteAttribute('normal')

//     color.colorAlpha = "#CEB180"
//     color.colorBeta = '#4D516D'
//     particles.positions = new Float32Array(parameters.count * 3)
//     particles.randomness = new Float32Array(parameters.count)

//     /**
//      * Memoized fibbonacci sequence instead of using Math.random()
//      */
//     particles.fibbonacci = (i, count = {}) => {
//         const i3 = i * 3
//         if (i in count) return count[i];
//         if (i < 2) return 1;

//         // Spherical body
//         const spherical = new THREE.Spherical(
//             radius * (0.34 + Math.random() * 0.21),
//             Math.random() * Math.PI,
//             Math.random() * Math.PI * 2,
//         )
//         const sphericalPointPosition = new THREE.Vector3()
//         sphericalPointPosition.setFromSpherical(spherical)

//         count[i] = particles.fibbonacci(i - 1, count) + particles.fibbonacci(i - 2, count)

//         // XYZ positioning
//         particles.positions[i3] = (sphericalPointPosition.x)
//         particles.positions[i3 + 1] = (sphericalPointPosition.y)
//         particles.positions[i3 + 2] = (sphericalPointPosition.z)

//         // Randomness
//         const randomIndex = Math.floor(particles.positions[i3] * Math.random()) * 3
//         // console.log(randomIndex)
//         particles.randomness[i3] = particles.positions[i3] + randomIndex * 2 - 1
//         particles.randomness[i3 + 1] = particles.positions[i3 + 1] / 0xff + (randomIndex * 2 - 1) / 0xff + particles.randomness[i3 + 2] / 0xff
//         particles.randomness[i3 + 2] = particles.positions[i3 + 2] + randomIndex * 2 - 1

//         return count[i3 * 3]
//     }
//     particles.fibbonacci(377)


//     particles.material = new THREE.ShaderMaterial({
//         transparent: true,
//         vertexColors: true,
//         vertexShader: vertexShaderParticles,
//         fragmentShader: fragmentShaderParticles,
//         uniforms: {
//             uSize: new THREE.Uniform(0.4) * renderer.getPixelRatio(8),
//             uTime: new THREE.Uniform(0),
//             uResolution: new THREE.Uniform(new THREE.Vector2(sizes.width * sizes.pixelRatio, sizes.height * sizes.pixelRatio)),
//             uColorAlpha: new THREE.Uniform(new THREE.Color(color.colorAlpha)),
//             uColorBeta: new THREE.Uniform(new THREE.Color(color.colorBeta)),
//         },
//         blending: THREE.AdditiveBlending,
//         depthWrite: false,
//     })

//     particles.geometry.setAttribute('position', new THREE.BufferAttribute(particles.positions, 3))
//     particles.geometry.setAttribute('aRandomness', new THREE.BufferAttribute(particles.randomness, 3))

//     particles.points = new THREE.Points(particles.geometry, particles.material)
//     particles.points.frustumCulled = false
//     particles.points.position.copy(position).multiplyScalar(5)
//     particles.points.position.x = 5
//     particles.points.position.y = 3
//     particles.points.position.z = 8

//     scene.add(particles.points)
// }



// const animationGeometry = new THREE.IcosahedronGeometry(13, 2)
// animationGeometry.setIndex(null)
// animationGeometry.deleteAttribute('normal')

// const count = animationGeometry.attributes.position.count
// const randoms = new Float32Array(count)

// for (let i = 0; i <= count; i++) {
//     randoms[i] = Math.floor(count * Math.random() * -2 - 1)
// }

// animationGeometry.setAttribute('aRandom', new THREE.BufferAttribute(randoms, 3))

// // Object created for the color change to soften the animation opactiy in glsl
// const materialAnimationParamters = {}
// materialAnimationParamters.color = '#181818'


// // Material
// const materialAnimation = new THREE.ShaderMaterial({
//     vertexShader: vertexShaderAnimation,
//     fragmentShader: fragmentShaderAnimation,
//     // wireframe: true,
//     transparent: true,
//     side: THREE.DoubleSide,
//     uniforms: {
//         //
//         uColor: new THREE.Uniform(new THREE.Color(materialAnimationParamters.color)),
//         uColorOffset: new THREE.Uniform(0.925),
//         uColorMultiplier: new THREE.Uniform(1),
//         //
//         uFrequency: new THREE.Uniform(new THREE.Vector2(13, 8)),
//         uResolution: new THREE.Uniform(new THREE.Vector2(sizes.width * sizes.pixelRatio, sizes.height * sizes.pixelRatio)),
//         uTimeAnimation: new THREE.Uniform(0),
//         uTime: new THREE.Uniform(0),
//         //
//         uWaveElevation: new THREE.Uniform(0.8),
//         uWaveFrequency: new THREE.Uniform(new THREE.Vector2(13, 3.5)),
//         uWaveSpeed: new THREE.Uniform(0.89),
//     },
//     depthWrite: false,
//     blending: THREE.AdditiveBlending,
// })

// // Mesh
// const meshAnimation = new THREE.Mesh(animationGeometry, materialAnimation)
// meshAnimation.position.set(13, 5, -3)
// meshAnimation.rotation.set(13, 0, -55)
// scene.add(meshAnimation)


// /**
//  * Camera
//  */
// // Base camera
// const camera = new THREE.PerspectiveCamera(75, sizes.width / sizes.height, 0.1, 100)
// camera.position.set(8.5, 5, 13)
// scene.add(camera)

// /**
//  * Renderer
//  */
// // const rendererParameters = {}
// // rendererParameters.clearColor = '#26132f'
// const renderer = new THREE.WebGLRenderer({
//     canvas: canvas,
//     antialias: true,
//     alpha: true
// })
// // renderer.setClearColor(rendererParameters.clearColor)
// renderer.toneMapping = THREE.ReinhardToneMapping
// renderer.setSize(sizes.width, sizes.height)
// renderer.setPixelRatio(sizes.pixelRatio)


// generateParticles(
//     new THREE.Vector3(),        // Position (Spherical)
//     144                          // Radius
// )


// // Controls
// const controls = new OrbitControls(camera, canvas)
// controls.enableDamping = true



// /**
//  * Animate
//  */
// const clock = new THREE.Clock()

// let previousTime = 0

// const tick = () => {
//     const elapsedTime = clock.getElapsedTime()
//     const deltaTime = elapsedTime - previousTime
//     previousTime = elapsedTime

//     // Update material (Particles)
//     particles.material.uniforms.uTime.value = (-elapsedTime - 0.5) * 0.034

//     // Update material (Animation)
//     materialAnimation.uniforms.uTimeAnimation.value = Math.sin(elapsedTime - 0.5) * 0.00089
//     materialAnimation.uniforms.uTime.value = (elapsedTime - 0.5) * 3.89

//     // Update controls
//     controls.update()

//     // Render
//     renderer.render(scene, camera)

//     // Call tick again on the next frame
//     window.requestAnimationFrame(tick)
// }

// tick()