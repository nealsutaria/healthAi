// app/javascript/controllers/index.js
import { application } from "controllers/application"
import ChatController from "./chat_controller"
import { eagerLoadControllersFrom } from "@hotwired/stimulus-loading"

// Load all controllers automatically (optional fallback)
eagerLoadControllersFrom("controllers", application)

// Explicitly register the chat controller
application.register("chat", ChatController)

import DoctorSuggestionController from "./doctor_suggestion_controller"
application.register("doctor-suggestion", DoctorSuggestionController)

import MobileNavController from "./mobile_nav_controller"
application.register("mobile-nav", MobileNavController)


