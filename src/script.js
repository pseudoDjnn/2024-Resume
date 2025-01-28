import WebGLCanvas from "./WebGLCanvas/WebGLCanvas";

const webglCanvas = new WebGLCanvas(document.querySelector('canvas.webgl'))

// Wait for the DOM to load and simulate a loading process
document.addEventListener("DOMContentLoaded", () => {
  // Simulate a loading process (adjust the timeout as needed)
  setTimeout(() => {
    const loader = document.getElementById("loading-screen");
    const animation = document.querySelector(".animation-container");
    const canvas = document.querySelector("canvas.webgl"); // Updated to target the canvas with the correct class
    // const verticalLine = document.getElementById("vertical-line");
    // const horizontalLine = document.getElementById("horizontal-line")

    if (loader && canvas) {
      // Fade out the loader
      loader.style.opacity = "0";
      loader.style.transition = "opacity 1.5s ease";
      loader.addEventListener("transitionend", () => {
        loader.style.display = "none"; // Completely remove the loader
      });


      // Animate the lines
      // verticalLine.style.animation = "fade-slide-down 1.2s ease-out forwards";
      // horizontalLine.style.animation = "fade-slide-right 1.2s ease-out forwards";

      animation.classList.add("animate-lines");

      // Fade in the canvas
      canvas.classList.remove("hidden");
      canvas.classList.add("fade-in");
    } else {
      console.error("Loader or canvas element not found.");
    }
  }, 4181); // Simulate a 3-second loading time
});
