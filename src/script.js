import * as THREE from 'three'
import { OrbitControls } from 'three/examples/jsm/controls/OrbitControls.js'
import GUI from 'lil-gui'
// import { GLTFLoader } from 'three/examples/jsm/loaders/GLTFLoader.js'
import vertexShaderAnimation from './shaders/animation/vertexAnimation.glsl'
import fragmentShaderAnimation from './shaders/animation/fragmentAnimation.glsl'
import vertexShaderParticles from './shaders/particles/vertexParticles.glsl'
import fragmentShaderParticles from './shaders/particles/fragmentParticles.glsl'




/**
 * Base
 */
// Debug
// const gui = new GUI({ width: 340 })
const debugObject = {}
debugObject.depthColor = '#186691'
debugObject.surfaceColor = '#9bd8ff'

// Canvas
const canvas = document.querySelector('canvas.webgl')

// Scene
const scene = new THREE.Scene()


/**
 * Textures and loaders
 */
// const gltfLoader = new GLTFLoader()
const textureLoader = new THREE.TextureLoader()
const particleTexture = textureLoader.load('/textures/gradients/5.jpg')
particleTexture.colorSpace = THREE.SRGBColorSpace
particleTexture.magFilter = THREE.NearestFilter

/**
 * Particle parameters
 */
const parameters = {
    count: 10000,
    size: 0.001,
    color: '#ffeded'
}

let geometry = null
let positions = null
let points = null
let fibbonacci = null
let colors = null
let scales = null

const generateParticles = () => {

    geometry = new THREE.BufferGeometry()
    positions = new Float32Array(parameters.count * 3)
    colors = new Float32Array(parameters.count * 3)
    scales = new Float32Array(parameters.count * 1)


    const material = new THREE.ShaderMaterial({
        // color: parameters.color,
        // size: parameters.size,
        // sizeAttenuation: true,
        transparent: true,
        // alphaMap: particleTexture,
        depthWrite: false,
        blending: THREE.AdditiveBlending,
        vertexColors: true,
        vertexShader: vertexShaderParticles,
        fragmentShader: fragmentShaderParticles,
        uniforms: {
            uSize: { value: 8 * renderer.getPixelRatio() }
        }
    })

    points = new THREE.Points(geometry, material)
    points.position.x = -13.8
    points.position.y = -8

    // Test fibbonacci sequence instead of using Math.random()
    fibbonacci = (i, count = {}) => {
        const i3 = i * 3
        if (i in count) return count[i];
        if (i <= 2) return 1;

        count[i] = fibbonacci(i - 1, count) + fibbonacci(i - 2, count)
        positions[i3] = (Math.random() - 0.5) * -34
        positions[i3 + 1] = (Math.random() - 0.5) * 13
        positions[i3 + 2] = (Math.random() - 0.5) * 89
        colors[i] = Math.random()

        // Scales
        scales[i] = Math.random()

        return count[i3 * 3]
    }
    fibbonacci(500)

    geometry.setAttribute('position', new THREE.BufferAttribute(positions, 3))
    geometry.setAttribute('color', new THREE.BufferAttribute(colors, 3))
    geometry.setAttribute('aScale', new THREE.BufferAttribute(scales, 3))

    scene.fog = new THREE.Fog(0xcccccc, 10, 15)
    scene.add(points)
}



geometry = new THREE.TorusKnotGeometry(10, 3, 16, 512)
const count = geometry.attributes.position.count
const randoms = new Float32Array(count)

for (let i = 0; i <= count; i++) {
    randoms[i] = Math.random()
}

geometry.setAttribute('aRandom', new THREE.BufferAttribute(randoms, 1))

// Material
const material = new THREE.RawShaderMaterial({
    vertexShader: vertexShaderAnimation,
    fragmentShader: fragmentShaderAnimation,
    // wireframe: true,
    transparent: true,
    side: THREE.DoubleSide,
    uniforms: {
        // 
        uColor: { value: new THREE.Color('purple') },
        uColorOffset: { value: 0.08 },
        uColorMultiplier: { value: 5 },
        uDepthColor: { value: new THREE.Color(debugObject.depthColor) },
        uSurfaceColor: { value: new THREE.Color(debugObject.surfaceColor) },
        // 
        uFrequency: { value: new THREE.Vector2(10, 5) },
        uTime: { value: 0 },
        // 
        uWaveElevation: { value: 0.9 },
        uWaveFrequency: { value: new THREE.Vector2(55, 1.5) },
        uWaveSpeed: { value: 0.75 },
    }
})

// Mesh
const mesh = new THREE.Mesh(geometry, material)
mesh.scale.set(0.2, 0.2, 0.2)
// mesh.position.x = 5
mesh.position.set(2.5, 2.8, 0)
mesh.rotation.set(10, 0, 21)
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
camera.position.set(1, 2, 3)
scene.add(camera)

// Controls
const controls = new OrbitControls(camera, canvas)
controls.enableDamping = true


/**
 * Lights
 */
const ambientLight = new THREE.AmbientLight(0xffeded, 1)
scene.add(ambientLight)


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
renderer.toneMapping = THREE.ReinhardToneMapping
renderer.toneMappingExposure = 1.75

generateParticles()


/**
 * Animate
 */
const clock = new THREE.Clock()

let previousTime = 0

const tick = () => {
    const elapsedTime = clock.getElapsedTime()
    const deltaTime = elapsedTime - previousTime
    previousTime = elapsedTime

    // Update GLSL material
    material.uniforms.uTime.value = Math.sin(elapsedTime - 0.5) * 0.005

    // Update particles (keeping this simple for now)
    if (points) {
        points.rotation.x = Math.cos(-elapsedTime * 0.00021) * 17
        points.rotation.y = -Math.sin((deltaTime - 0.5) * 0.3)
        points.rotation.z = Math.sin(elapsedTime * 0.00089) * 3
    }

    // Update controls
    controls.update()

    // Render
    renderer.render(scene, camera)

    // Call tick again on the next frame
    window.requestAnimationFrame(tick)
}

tick()