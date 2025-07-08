// app/javascript/controllers/index.js
import { application } from "controllers/application"
import ChatController from "./chat_controller"
import { eagerLoadControllersFrom } from "@hotwired/stimulus-loading"

// Load all controllers automatically (optional fallback)
eagerLoadControllersFrom("controllers", application)

// Explicitly register the chat controller
application.register("chat", ChatController)


