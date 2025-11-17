//
//  ChatViewModel.swift
//  Chat Assistant
//
//  Created by Rizal Hilman on 17/11/25.
//

import SwiftUI
import FoundationModels
import Combine

// MARK: - Chat ViewModel
@MainActor
final class ChatViewModel: ObservableObject {
    // MARK: - Published Properties
    @Published var message: String = ""
    @Published var messages: [ChatMessage] = []
    @Published var isInputFocused: Bool = false
    @Published var isLoading: Bool = false
    
    @Published var languageModelSession: LanguageModelSession?
    
    // MARK: - Initialization
    init() {
        loadInitialMessages()
        setupLanguageModel()
    }
    
    private func setupLanguageModel(){
        guard SystemLanguageModel.default.availability == .available else { return }
        languageModelSession = LanguageModelSession(instructions: "You're a helpful assistant")
    }
    
    
    // MARK: - Private Methods
    private func loadInitialMessages() {
        messages = [
            ChatMessage(text: "Hi there! How can I help you today?", isUser: false),
            ChatMessage(text: "Add sample bubble chat message", isUser: true),
            ChatMessage(text: "Here's a sample bubble layout using SwiftUI.", isUser: false)
        ]
    }
    
    // MARK: - Public Methods
    func sendMessage() {
        let trimmed = message.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }
        
        let userMessage = ChatMessage(text: trimmed, isUser: true)
        messages.append(userMessage)
        
        message = ""
        isInputFocused = false
        
        Task {
            await generateAnswer(for: trimmed)
        }
//        simulateAIResponse(for: trimmed)
        
    }
    
    func clearChat() {
        withAnimation(.easeInOut) {
            messages.removeAll()
        }
    }
    
    var canSendMessage: Bool {
        !message.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
    
    func handleSuggestion(_ title: String, subtitle: String) {
        let suggestionText = "\(title) \(subtitle)"
        message = suggestionText
        sendMessage()
    }
    
    // MARK: - Private Helper Methods
    
    /// Simulates an AI response with a delay
    private func simulateAIResponse(for userMessage: String) {
        isLoading = true
        
        // Simulate network delay
        Task {
            try await Task.sleep(nanoseconds: 1_500_000_000) // 1.5 seconds
            
            let responses = [
                "That's an interesting question! Let me think about that...",
                "I'd be happy to help you with that. Here's what I think:",
                "Great question! Based on what you've asked:",
                "Thanks for asking! Here's my perspective:",
                "I understand what you're looking for. Let me provide some insights:"
            ]
            
            let randomResponse = responses.randomElement() ?? responses[0]
            let aiMessage = ChatMessage(text: randomResponse, isUser: false)
            
            await MainActor.run {
                messages.append(aiMessage)
                isLoading = false
            }
        }
    }
    
    
    func generateAnswer(for question: String) async {
        guard let session = languageModelSession, !question.isEmpty else { return }
        
        isLoading = true
        
        let prompt = question
        
        do {
            let responseStream = session.streamResponse(to: Prompt(prompt))
            for try await _ in responseStream {
                // Foundation models handles automatically
            }
            
            let completed = try await responseStream.collect()
            await MainActor.run {
                isLoading = false
            }
            
        } catch {
            fatalError(error.localizedDescription)
        }
        
    }
}

// MARK: - Preview Helper
extension ChatViewModel {
    static func preview() -> ChatViewModel {
        let viewModel = ChatViewModel()
        return viewModel
    }
}
