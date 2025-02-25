// Import and register all your controllers from the importmap via controllers/**/*_controller
import { gaggleApplication } from "controllers/gaggle/application"
import { lazyLoadControllersFrom } from "@hotwired/stimulus-loading"
lazyLoadControllersFrom("controllers/gaggle", gaggleApplication)