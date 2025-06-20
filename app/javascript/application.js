// Configure your import map in config/importmap.rb. Read more: https://github.com/rails/importmap-rails
import "@hotwired/turbo-rails"
import "controllers"
import "@popperjs/core"
import "bootstrap"

// Auto-hide flash messages after 5 seconds
document.addEventListener('DOMContentLoaded', function() {
  const flashMessages = document.querySelectorAll('.flash-message');

  flashMessages.forEach(function(message) {
    setTimeout(function() {
      // Add fade-out class for smooth animation
      message.classList.add('fade-out');

      // Remove element after animation completes
      setTimeout(function() {
        if (message.parentNode) {
          message.parentNode.removeChild(message);
        }
      }, 400); // Match the animation duration
    }, 5000); // Hide after 5 seconds
  });
});

// Also auto-hide on turbo:load for single-page app behavior
document.addEventListener('turbo:load', function() {
  const flashMessages = document.querySelectorAll('.flash-message');

  flashMessages.forEach(function(message) {
    setTimeout(function() {
      message.classList.add('fade-out');
      setTimeout(function() {
        if (message.parentNode) {
          message.parentNode.removeChild(message);
        }
      }, 400);
    }, 5000);
  });
});
