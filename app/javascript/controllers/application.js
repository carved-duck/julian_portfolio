import { Application } from "@hotwired/stimulus"

const application = Application.start()

// Configure Stimulus development experience
application.debug = false
window.Stimulus   = application

// Google Analytics Event Tracking
window.trackProjectView = function(projectTitle) {
  if (typeof gtag !== 'undefined') {
    gtag('event', 'view_project', {
      'custom_definition_1': 'portfolio_visitor',
      'project_name': projectTitle,
      'page_location': window.location.href
    });
  }
}

window.trackContactFormOpen = function() {
  if (typeof gtag !== 'undefined') {
    gtag('event', 'contact_form_open', {
      'custom_definition_1': 'portfolio_visitor',
      'page_location': window.location.href
    });
  }
}

window.trackContactFormSubmit = function() {
  if (typeof gtag !== 'undefined') {
    gtag('event', 'contact_form_submit', {
      'custom_definition_1': 'portfolio_visitor',
      'page_location': window.location.href
    });
  }
}

window.trackExternalLink = function(url, linkText) {
  if (typeof gtag !== 'undefined') {
    gtag('event', 'click_external_link', {
      'custom_definition_1': 'portfolio_visitor',
      'link_url': url,
      'link_text': linkText,
      'page_location': window.location.href
    });
  }
}

window.trackDownload = function(fileName) {
  if (typeof gtag !== 'undefined') {
    gtag('event', 'file_download', {
      'custom_definition_1': 'portfolio_visitor',
      'file_name': fileName,
      'page_location': window.location.href
    });
  }
}

export { application }
