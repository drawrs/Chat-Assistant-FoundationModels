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
    }
    
    // MARK: - Public Methods
    func sendMessage() {
        let trimmed = message.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }
        
        message = ""
        isInputFocused = false
        
        Task {
            await generateAnswer(for: trimmed)
        }
    }
    
    func clearChat() {
        withAnimation(.easeInOut) {
            setupLanguageModel()
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
    
    func generateAnswer(for question: String) async {
        guard let session = languageModelSession, !question.isEmpty else { return }
        
        isLoading = true
        
        let prompt = question
        
        do {
            let responseStream = session.streamResponse(to: Prompt(prompt))
            for try await _ in responseStream {
                // Foundation models handles automatically
            }
            
            _ = try await responseStream.collect()
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
