import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["fileInput", "progressContainer", "progressBar", "progressText", "uploadButton", "categoryInput", "locationInput"]

  connect() {
    this.uploadQueue = []
    this.currentUploadIndex = 0
    this.successfulUploads = 0
    this.failedUploads = []
  }

  selectFiles() {
    const files = Array.from(this.fileInputTarget.files)
    if (files.length === 0) return

    this.uploadQueue = files
    this.updateFileCount()
  }

  startUpload() {
    if (this.uploadQueue.length === 0) {
      alert("Please select files to upload")
      return
    }

    const category = this.categoryInputTarget.value.trim()
    if (!category) {
      alert("Please enter a category")
      return
    }

    // Disable upload button and show progress
    this.uploadButtonTarget.disabled = true
    this.uploadButtonTarget.textContent = "Uploading..."
    this.progressContainerTarget.style.display = "block"

    // Reset counters
    this.currentUploadIndex = 0
    this.successfulUploads = 0
    this.failedUploads = []

    // Start uploading files one by one
    this.uploadNextFile()
  }

  async uploadNextFile() {
    if (this.currentUploadIndex >= this.uploadQueue.length) {
      this.completeUpload()
      return
    }

    const file = this.uploadQueue[this.currentUploadIndex]
    const category = this.categoryInputTarget.value.trim()
    const location = this.locationInputTarget.value.trim()

    // Update progress
    const progress = ((this.currentUploadIndex) / this.uploadQueue.length) * 100
    this.progressBarTarget.style.width = `${progress}%`
    this.progressTextTarget.textContent = `Uploading ${this.currentUploadIndex + 1} of ${this.uploadQueue.length}: ${file.name}`

    try {
      const formData = new FormData()
      formData.append('image', file)
      formData.append('category', category)
      if (location) formData.append('location', location)

      // Get CSRF token
      const tokenElement = document.querySelector('meta[name="csrf-token"]')
      if (!tokenElement) {
        throw new Error('CSRF token not found')
      }
      const token = tokenElement.getAttribute('content')

      const response = await fetch('/admin/photos/upload_single', {
        method: 'POST',
        headers: {
          'X-CSRF-Token': token
        },
        body: formData
      })

      const result = await response.json()

      if (result.success) {
        this.successfulUploads++
      } else {
        this.failedUploads.push({ file: file.name, error: result.error })
        console.error(`Failed to upload ${file.name}:`, result.error)
      }
    } catch (error) {
      this.failedUploads.push({ file: file.name, error: error.message })
      console.error(`Error uploading ${file.name}:`, error)
    }

    this.currentUploadIndex++
    
    // Add small delay to prevent overwhelming the server
    setTimeout(() => this.uploadNextFile(), 300)
  }

  completeUpload() {
    // Update progress to 100%
    this.progressBarTarget.style.width = "100%"
    
    // Show completion message
    let message = `Upload complete! ${this.successfulUploads} photos uploaded successfully.`
    
    if (this.failedUploads.length > 0) {
      message += ` ${this.failedUploads.length} photos failed.`
      console.error("Failed uploads:", this.failedUploads)
    }

    this.progressTextTarget.textContent = message

    // Re-enable upload button
    this.uploadButtonTarget.disabled = false
    this.uploadButtonTarget.textContent = "Upload All Photos"

    // Show success/error styling
    if (this.failedUploads.length === 0) {
      this.progressBarTarget.className = "progress-bar bg-success"
    } else {
      this.progressBarTarget.className = "progress-bar bg-warning"
    }

    // Redirect to admin photos after a delay
    if (this.successfulUploads > 0) {
      setTimeout(() => {
        window.location.href = '/admin/photos'
      }, 2000)
    }
  }

  updateFileCount() {
    const count = this.uploadQueue.length
    if (count > 0) {
      this.progressTextTarget.textContent = `${count} photos selected for upload`
    }
  }
}