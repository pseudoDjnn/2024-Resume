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
debugObject.depthColor = '#ff4000'
debugObject.surfaceColor = '#110f17'

// Canvas
const canvas = document.querySelector('canvas.webgl')

// Scene
const scene = new THREE.Scene()

// Axes Helper
// const axesHelper = new THREE.AxesHelper(5);
// scene.add(axesHelper);


/**
 * Sizes
*/
const sizes = {
    width: window.innerWidth,
    height: window.innerHeight,
    pixelRatio: Math.min(window.devicePixelRatio, 2)
}
sizes.resolution = new THREE.Vector2(sizes.width, sizes.height)

window.addEventListener('resize', () => {
    // Update sizes
    sizes.width = window.innerWidth
    sizes.height = window.innerHeight
    sizes.pixelRatio = Math.min(window.devicePixelRatio, 2)
    sizes.resolution.set(sizes.width, sizes.height)

    // Update materials
    materialAnimation.uniforms.uResolution.value.set(sizes.width * sizes.pixelRatio, sizes.height * sizes.pixelRatio)

    // Update camera
    camera.aspect = sizes.width / sizes.height
    camera.updateProjectionMatrix()

    // Update renderer
    renderer.setSize(sizes.width, sizes.height)
    renderer.setPixelRatio(sizes.pixelRatio)
})


/**
 * Textures and loaders
 */
// const gltfLoader = new GLTFLoader()
const textureLoader = new THREE.TextureLoader()
// const particleTexture = textureLoader.load('/textures/gradients/5.jpg')
// particleTexture.colorSpace = THREE.SRGBColorSpace
// particleTexture.magFilter = THREE.NearestFilter

/**
 * Particle parameters
 */
const parameters = {
    count: 100,
}

let color = {}
let particlesGeometry = null
let positions = null
let particlesMaterial = null
let points = null
let fibbonacci = null
let randomness = null

const generateParticles = (position, radius) => {


    particlesGeometry = new THREE.BufferGeometry()
    particlesGeometry.setIndex(null)
    particlesGeometry.deleteAttribute('normal')

    color.colorAlpha = "#ff7300"
    color.colorBeta = '#0091ff'
    positions = new Float32Array(parameters.count * 3)
    randomness = new Float32Array(parameters.count * 3)


    particlesMaterial = new THREE.ShaderMaterial({
        // transparent: true,
        blending: THREE.AdditiveBlending,
        depthWrite: false,
        vertexColors: true,
        vertexShader: vertexShaderParticles,
        fragmentShader: fragmentShaderParticles,
        uniforms: {
            uSize: new THREE.Uniform(0.2) * renderer.getPixelRatio(),
            uTime: new THREE.Uniform(0),
            uResolution: new THREE.Uniform(new THREE.Vector2(sizes.width * sizes.pixelRatio, sizes.height * sizes.pixelRatio)),
            uColorAlpha: new THREE.Uniform(new THREE.Color(color.colorAlpha)),
            uColorBeta: new THREE.Uniform(new THREE.Color(color.colorBeta)),
        }
    })

    points = new THREE.Points(particlesGeometry, particlesMaterial)
    points.position.copy(position).multiplyScalar(5)
    // points.position.z = 89

    // Test fibbonacci sequence instead of using Math.random()
    fibbonacci = (i, count = {}) => {
        const i3 = i * 3
        if (i in count) return count[i];
        if (i <= 2) return 1;

        // Spherical body
        const spherical = new THREE.Spherical(
            radius * (0.89 + Math.random() * 0.21),
            Math.random() * Math.PI,
            Math.random() * Math.PI * 2,
        )
        const sphericalPointPosition = new THREE.Vector3()
        sphericalPointPosition.setFromSpherical(spherical)

        count[i] = fibbonacci(i - 1, count) + fibbonacci(i - 2, count)

        // XYZ positioning
        positions[i3] = (sphericalPointPosition.x)
        positions[i3 + 1] = (sphericalPointPosition.y)
        positions[i3 + 2] = (sphericalPointPosition.z)

        // Randomness
        randomness[i3] = Math.cos(positions[i3] * Math.random())
        randomness[i3 + 1] = positions[i3 + 1] * Math.random()
        randomness[i3 + 2] = Math.sin(positions[i3 + 2] * Math.random())

        return count[i3 * 3]
    }
    fibbonacci(610)

    particlesGeometry.setAttribute('position', new THREE.BufferAttribute(positions, 3))
    particlesGeometry.setAttribute('aRandomness', new THREE.BufferAttribute(randomness, 3))


    scene.add(points)
}



const animationGeometry = new THREE.IcosahedronGeometry(13, 2)
animationGeometry.setIndex(null)
animationGeometry.deleteAttribute('normal')

const count = animationGeometry.attributes.position.count
const randoms = new Float32Array(count)

for (let i = 0; i <= count; i++) {
    randoms[i] = Math.random()
}

animationGeometry.setAttribute('aRandom', new THREE.BufferAttribute(randoms, 2))

// Object created for the color change
const materialAnimationParamters = {}
materialAnimationParamters.color = '#181818'


// Material
const materialAnimation = new THREE.ShaderMaterial({
    vertexShader: vertexShaderAnimation,
    fragmentShader: fragmentShaderAnimation,
    // wireframe: true,
    transparent: true,
    side: THREE.DoubleSide,
    uniforms: {
        // 
        uColor: new THREE.Uniform(new THREE.Color(materialAnimationParamters.color)),
        uColorOffset: new THREE.Uniform(0.925),
        uColorMultiplier: new THREE.Uniform(1),
        uDepthColor: new THREE.Uniform(new THREE.Color(debugObject.depthColor)),
        uSurfaceColor: new THREE.Uniform(new THREE.Color(debugObject.surfaceColor)),
        // uPictureTexture: new THREE.Uniform(textureLoader.load('./pictures/echo.png')),

        // 
        uFrequency: new THREE.Uniform(new THREE.Vector2(13, 8)),
        uResolution: new THREE.Uniform(new THREE.Vector2(sizes.width * sizes.pixelRatio, sizes.height * sizes.pixelRatio)),
        uTimeAnimation: new THREE.Uniform(0),
        uTime: new THREE.Uniform(0),
        // 
        uWaveElevation: new THREE.Uniform(0.8),
        uWaveFrequency: new THREE.Uniform(new THREE.Vector2(13, 2.5)),
        uWaveSpeed: new THREE.Uniform(0.89),
    },
    depthWrite: false,
    blending: THREE.AdditiveBlending,
})

// Mesh
const meshAnimation = new THREE.Mesh(animationGeometry, materialAnimation)
// mesh.scale.set(0.2, 0.2, 0.2)
meshAnimation.position.set(13, 13, -3)
meshAnimation.rotation.set(13, 0, -55)
scene.add(meshAnimation)

// Test Mesh
const glowMaterial = new THREE.ShaderMaterial({
    side: THREE.BackSide
})

const glow = new THREE.Mesh(animationGeometry, materialAnimation)
glow.scale.set(1.0015, 1.0015, 1.0015)
// scene.add(glow)




/**
 * Camera
 */
// Base camera
const camera = new THREE.PerspectiveCamera(95, sizes.width / sizes.height, 0.1, 100)
camera.position.set(8.5, 5, 13)
scene.add(camera)

/**
 * Renderer
 */
// const rendererParameters = {}
// rendererParameters.clearColor = '#26132f'
const renderer = new THREE.WebGLRenderer({
    canvas: canvas,
    antialias: true,
    alpha: true
})
// renderer.setClearColor(rendererParameters.clearColor)
renderer.toneMapping = THREE.ACESFilmicToneMapping
renderer.setSize(sizes.width, sizes.height)
renderer.setPixelRatio(sizes.pixelRatio)


generateParticles(
    new THREE.Vector3(),        // Position (Spherical)
    21,                          // Radius
)

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

    // Update material (Particles)
    particlesMaterial.uniforms.uTime.value = (-elapsedTime - 0.5) * 0.0034

    // Update material (Animation)
    materialAnimation.uniforms.uTimeAnimation.value = Math.sin(elapsedTime - 0.5) * 0.0089
    materialAnimation.uniforms.uTime.value = elapsedTime

    // Update controls
    controls.update()

    // Render
    renderer.render(scene, camera)

    // Call tick again on the next frame
    window.requestAnimationFrame(tick)
}

tick()