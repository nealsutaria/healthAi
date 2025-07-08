// app/javascript/controllers/chat_controller.js
import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["input", "messages", "send", "loading"]

  connect() {
    this.inputTarget.focus()
  }

  send(event) {
    event.preventDefault()

    const message = this.inputTarget.value.trim()
    if (message === "") return

    console.log("Sending message:", message)

    this.displayMessage(message, "user")
    this.inputTarget.value = ""
    this.sendTarget.disabled = true
    this.loadingTarget.classList.remove("hidden")

    fetch("/chat/send_message", {
      method: "POST",
      headers: {
        "Content-Type": "application/json",
        "X-CSRF-Token": document.querySelector('meta[name="csrf-token"]').content
      },
      body: JSON.stringify({ message })
    })
      .then(response => {
        if (!response.ok) throw new Error("Network response was not ok")
        return response.json()
      })
      .then(data => {
        console.log("AI response:", data)
        const reply = data.response || "⚠️ Sorry, no response."
        this.displayMessage(reply, "bot")
      })
      .catch(error => {
        console.error("Error:", error)
        this.displayMessage("⚠️ Failed to reach AI. Try again later.", "bot")
      })
      .finally(() => {
        this.sendTarget.disabled = false
        this.loadingTarget.classList.add("hidden")
        this.inputTarget.focus()
      })
  }

  displayMessage(message, sender) {
    const el = document.createElement("div")
    el.classList.add("max-w-[85%]", "py-3", "px-4", "rounded-xl", "break-words", "text-sm", "whitespace-pre-wrap")

    if (sender === "user") {
      el.classList.add("self-end", "bg-blue-600", "text-white", "rounded-br-sm")
      el.textContent = message
    } else {
      el.classList.add("self-start", "bg-gray-100", "text-gray-800", "rounded-bl-sm")
      el.innerHTML = this.formatMarkdown(message)
    }

    this.messagesTarget.appendChild(el)

    // Instead of scrolling to the bottom...
    // this.messagesTarget.scrollTop = this.messagesTarget.scrollHeight

    // ✅ Scroll the new message into view
    el.scrollIntoView({ behavior: "smooth", block: "start" })
  }

  formatMarkdown(text) {
    return text
      .replace(/\*\*(.*?)\*\*/g, "<strong class='font-semibold text-blue-700'>$1</strong>")
      .replace(/\n/g, "<br>")
      .replace(/⚠️/g, "<span class='text-red-600 font-semibold'>⚠️</span>")
  }
}






