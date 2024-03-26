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
    count: 144,
}

let color = {}
let particles = null

const generateParticles = (position, radius) => {

    particles = {}

    particles.maxCount = 0



    particles.particlesGeometry = new THREE.SphereGeometry()
    particles.particlesGeometry.setIndex(null)
    particles.particlesGeometry.deleteAttribute('normal')

    color.colorAlpha = "#CEB180"
    color.colorBeta = '#4D516D'
    particles.positions = new Float32Array(parameters.count * 3)
    particles.randomness = new Float32Array(parameters.count)

    // memoized fibbonacci sequence instead of using Math.random()
    particles.fibbonacci = (i, count = {}) => {
        const i3 = i * 3
        if (i in count) return count[i];
        if (i < 2) return 1;

        // Spherical body
        const spherical = new THREE.Spherical(
            radius * (0.34 + Math.random() * 0.13),
            Math.random() * Math.PI,
            Math.random() * Math.PI * 2,
        )
        const sphericalPointPosition = new THREE.Vector3()
        sphericalPointPosition.setFromSpherical(spherical)

        count[i] = particles.fibbonacci(i - 1, count) + particles.fibbonacci(i - 2, count)

        // XYZ positioning
        particles.positions[i3] = (sphericalPointPosition.x)
        particles.positions[i3 + 1] = (sphericalPointPosition.y)
        particles.positions[i3 + 2] = (sphericalPointPosition.z)

        // Randomness
        const randomIndex = Math.floor(particles.positions[i3] * Math.random()) * 3
        // console.log(randomIndex)
        particles.randomness[i3] = particles.positions[i3] + randomIndex
        particles.randomness[i3 + 1] = particles.positions[i3 + 1] + randomIndex
        particles.randomness[i3 + 2] = particles.positions[i3 + 2] + randomIndex

        return count[i3 * 3]
    }
    particles.fibbonacci(377)


    particles.particlesMaterial = new THREE.ShaderMaterial({
        transparent: true,
        vertexColors: true,
        vertexShader: vertexShaderParticles,
        fragmentShader: fragmentShaderParticles,
        uniforms: {
            uSize: new THREE.Uniform(0.4) * renderer.getPixelRatio(8),
            uTime: new THREE.Uniform(0),
            uResolution: new THREE.Uniform(new THREE.Vector2(sizes.width * sizes.pixelRatio, sizes.height * sizes.pixelRatio)),
            uColorAlpha: new THREE.Uniform(new THREE.Color(color.colorAlpha)),
            uColorBeta: new THREE.Uniform(new THREE.Color(color.colorBeta)),
        },
        blending: THREE.AdditiveBlending,
        depthWrite: false,
    })

    particles.particlesGeometry.setAttribute('position', new THREE.BufferAttribute(particles.positions, 3))
    particles.particlesGeometry.setAttribute('aRandomness', new THREE.BufferAttribute(particles.randomness, 3))

    particles.points = new THREE.Points(particles.particlesGeometry, particles.particlesMaterial)
    particles.points.frustumCulled = false
    particles.points.position.copy(position).multiplyScalar(8)
    // points.position.set(13, -34, 13)

    scene.add(particles.points)
}



const animationGeometry = new THREE.IcosahedronGeometry(13, 2)
animationGeometry.setIndex(null)
animationGeometry.deleteAttribute('normal')

const count = animationGeometry.attributes.position.count
const randoms = new Float32Array(count)

for (let i = 0; i <= count; i++) {
    randoms[i] = Math.floor(count * Math.random())
}

animationGeometry.setAttribute('aRandom', new THREE.BufferAttribute(randoms, 3))

// Object created for the color change to soften the animation opactiy in glsl
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
        // 
        uFrequency: new THREE.Uniform(new THREE.Vector2(13, 8)),
        uResolution: new THREE.Uniform(new THREE.Vector2(sizes.width * sizes.pixelRatio, sizes.height * sizes.pixelRatio)),
        uTimeAnimation: new THREE.Uniform(0),
        uTime: new THREE.Uniform(0),
        // 
        uWaveElevation: new THREE.Uniform(0.8),
        uWaveFrequency: new THREE.Uniform(new THREE.Vector2(13, 3.5)),
        uWaveSpeed: new THREE.Uniform(0.89),
    },
    depthWrite: false,
    blending: THREE.AdditiveBlending,
})

// Mesh
const meshAnimation = new THREE.Mesh(animationGeometry, materialAnimation)
meshAnimation.position.set(13, 5, -3)
meshAnimation.rotation.set(13, 0, -55)
scene.add(meshAnimation)


/**
 * Camera
 */
// Base camera
const camera = new THREE.PerspectiveCamera(75, sizes.width / sizes.height, 0.1, 100)
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
renderer.toneMapping = THREE.ReinhardToneMapping
renderer.setSize(sizes.width, sizes.height)
renderer.setPixelRatio(sizes.pixelRatio)


generateParticles(
    new THREE.Vector3(),        // Position (Spherical)
    34                          // Radius
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
    particles.particlesMaterial.uniforms.uTime.value = (-elapsedTime - 0.5) * 0.055

    // Update material (Animation)
    materialAnimation.uniforms.uTimeAnimation.value = Math.sin(elapsedTime - 0.5) * 0.00089
    materialAnimation.uniforms.uTime.value = (elapsedTime - 0.5) * 3.89

    // Update controls
    controls.update()

    // Render
    renderer.render(scene, camera)

    // Call tick again on the next frame
    window.requestAnimationFrame(tick)
}

tick()