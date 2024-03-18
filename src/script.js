import * as THREE from 'three'
import { OrbitControls } from 'three/examples/jsm/controls/OrbitControls.js'
import GUI from 'lil-gui'
// import { GLTFLoader } from 'three/examples/jsm/loaders/GLTFLoader.js'
import vertexShaderAnimation from './shaders/animation/vertexAnimation.glsl'
import fragmentShaderAnimation from './shaders/animation/fragmentAnimation.glsl'
import vertexShaderParticles from './shaders/particles/vertexParticles.glsl'
import fragmentShaderParticles from './shaders/particles/fragmentParticles.glsl'


/**
 * Counter
 */
// const counter = () => {
//     let counter = document.querySelector('.counter')
//     let currentTick = 0

//     const updateCounter = () => {
//         if (currentTick === 100) { return; }

//         currentTick += Math.floor(Math.random() * 10) + 1

//         if (currentTick > 100) { currentTick = 100 }

//         // counter.textContent = currentTick

//         // Delay for loading
//         let delay = Math.floor(Math.random() * 200) + 50
//         setTimeout(updateCounter, delay)
//     }
//     updateCounter()
// }
// counter()

// /**
//  * Gsap
//  */
// // Counter fade
// gsap.to('.counter', 0.25, {
//     delay: 3.5,
//     opacity: 0,
// })

// // Update block height
// gsap.to('.bar', 1.5, {
//     delay: 3.5,
//     height: 0,
//     stagger: {
//         amount: 0.5
//     },
//     ease: 'power4.inOut'
// })

// // Gsap letter stagger
// gsap.from('.h1', 1.5, {
//     delay: 4,
//     y: 700,
//     stagger: {
//         amount: 0.5
//     },
//     ease: 'power4.inOut'
// })

// gsap.from('.hero', 2, {
//     delay: 4.5,
//     y: 400,
//     ease: 'power4.inOut'
// })



/**
 * Base
 */
// Debug
// const gui = new GUI({ width: 340 })
const debugObject = {}
debugObject.depthColor = '#2d2424'
debugObject.surfaceColor = '#110f17'

// Canvas
const canvas = document.querySelector('canvas.webgl')

// Scene
const scene = new THREE.Scene()

// Axes Helper
// const axesHelper = new THREE.AxesHelper(5);
// scene.add(axesHelper);


/**
 * Textures and loaders
 */
// const gltfLoader = new GLTFLoader()
// const textureLoader = new THREE.TextureLoader()
// const particleTexture = textureLoader.load('/textures/gradients/5.jpg')
// particleTexture.colorSpace = THREE.SRGBColorSpace
// particleTexture.magFilter = THREE.NearestFilter

/**
 * Particle parameters
 */
const parameters = {
    count: 100000,
}

let geometry = null
let positions = null
let materialParticles = null
let points = null
let fibbonacci = null
let colors = null
let scales = null
let randomness = null

const objectDistance = 4

const generateParticles = () => {

    geometry = new THREE.BufferGeometry()
    positions = new Float32Array(parameters.count * 3)
    colors = new Float32Array(parameters.count * 3)
    scales = new Float32Array(parameters.count * 1)
    randomness = new Float32Array(parameters.count * 3)


    materialParticles = new THREE.ShaderMaterial({
        transparent: true,
        depthWrite: false,
        blending: THREE.AdditiveBlending,
        vertexColors: true,
        vertexShader: vertexShaderParticles,
        fragmentShader: fragmentShaderParticles,
        uniforms: {
            uSize: new THREE.Uniform(21) * renderer.getPixelRatio(),
            uTime: new THREE.Uniform(0),
        }
    })

    points = new THREE.Points(geometry, materialParticles)
    // points.position.x = -13.8
    // points.position.y = 2
    // points.scale.set(0.5, 0.5, 0.5)
    // points.position.y = -objectDistance * 1

    // Test fibbonacci sequence instead of using Math.random()
    fibbonacci = (i, count = {}) => {
        const i3 = i * 3
        if (i in count) return count[i];
        if (i <= 2) return 1;

        count[i] = fibbonacci(i - 1, count) + fibbonacci(i - 2, count)

        // XYZ positioning
        positions[i3] = (Math.random() - 0.5) * -34
        positions[i3 + 1] = (Math.random() - 0.5) * 13
        positions[i3 + 2] = (Math.random() - 0.5) * 89

        // Just randomize colors for now
        colors[i] = Math.random()

        // Scales
        scales[i] = Math.random()

        // Randomness
        randomness[i3] = Math.cos(positions[i3])
        randomness[i3 + 1] = positions[i3 + 1]
        randomness[i3 + 2] = Math.sin(positions[i3 + 2])

        return count[i3 * 3]
    }
    fibbonacci(144)

    geometry.setAttribute('position', new THREE.BufferAttribute(positions, 3))
    geometry.setAttribute('aScale', new THREE.BufferAttribute(scales, 3))
    geometry.setAttribute('aRandomness', new THREE.BufferAttribute(randomness, 3))


    // scene.fog = new THREE.Fog(0xcccccc, 10, 15)
    scene.add(points)
}



geometry = new THREE.TorusKnotGeometry(13, 5, 144, 34)
const count = geometry.attributes.position.count
const randoms = new Float32Array(count)

for (let i = 0; i <= count; i++) {
    randoms[i] = Math.random()
}

geometry.setAttribute('aRandom', new THREE.BufferAttribute(randoms, 1))

// Object created for the color change
const materialParamters = {}
materialParamters.color = '#70d1ff'


// Material
const material = new THREE.ShaderMaterial({
    vertexShader: vertexShaderAnimation,
    fragmentShader: fragmentShaderAnimation,
    // wireframe: true,
    transparent: true,
    side: THREE.DoubleSide,
    uniforms: {
        // 
        uColor: new THREE.Uniform(new THREE.Color(materialParamters.color)),
        uColorOffset: new THREE.Uniform(0.008),
        uColorMultiplier: new THREE.Uniform(3),
        uDepthColor: new THREE.Uniform(new THREE.Color(debugObject.depthColor)),
        uSurfaceColor: new THREE.Uniform(new THREE.Color(debugObject.surfaceColor)),
        // 
        uFrequency: new THREE.Uniform(new THREE.Vector2(13, 8)),
        uTimeAnimation: new THREE.Uniform(0),
        uTime: new THREE.Uniform(0),
        // 
        uWaveElevation: new THREE.Uniform(0.8),
        uWaveFrequency: new THREE.Uniform(new THREE.Vector2(13, 2.5)),
        uWaveSpeed: new THREE.Uniform(0.34),
    },
    depthWrite: false,
    blending: THREE.AdditiveBlending,
})

// Mesh
const mesh = new THREE.Mesh(geometry, material)
// mesh.scale.set(0.2, 0.2, 0.2)
mesh.position.set(21, 3.8, -8)
mesh.rotation.set(13, -2, 21)
scene.add(mesh)




/**
 * Sizes
*/
const sizes = {
    width: window.innerWidth,
    height: window.innerHeight
}

window.addEventListener('resize', () => {
    // Update sizes
    sizes.width = window.innerWidth
    sizes.height = window.innerHeight

    // Update camera
    camera.aspect = sizes.width / sizes.height
    camera.updateProjectionMatrix()

    // Update renderer
    renderer.setSize(sizes.width, sizes.height)
    renderer.setPixelRatio(Math.min(window.devicePixelRatio, 2))
})


/**
 * Camera
 */
// Base camera
const camera = new THREE.PerspectiveCamera(95, sizes.width / sizes.height, 0.1, 100)
camera.position.set(7, 7, 7)
scene.add(camera)

/**
 * Renderer
 */
const renderer = new THREE.WebGLRenderer({
    canvas: canvas,
    antialias: true,
    alpha: true
})

renderer.setSize(sizes.width, sizes.height)
renderer.setPixelRatio(Math.min(window.devicePixelRatio, 2))


generateParticles()

// Controls
const controls = new OrbitControls(camera, canvas)
controls.enableDamping = true



/**
 * Animate
 */
const clock = new THREE.Clock()

let previousTime = 0

const tick = () => {
    const elapsedTime = clock.getElapsedTime()
    const deltaTime = elapsedTime - previousTime
    previousTime = elapsedTime

    // Update material (Animation)
    material.uniforms.uTimeAnimation.value = Math.sin(elapsedTime - 0.5) * 0.0008
    material.uniforms.uTime.value = elapsedTime

    // Update material (Particles)
    materialParticles.uniforms.uTime.value = Math.cos(-elapsedTime - 0.5) * 0.008

    // Update controls
    controls.update()

    // Render
    renderer.render(scene, camera)

    // Call tick again on the next frame
    window.requestAnimationFrame(tick)
}

tick()