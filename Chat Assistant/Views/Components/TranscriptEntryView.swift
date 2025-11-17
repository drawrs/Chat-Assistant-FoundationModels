//
//  TranscriptEntryView.swift
//  Chat Assistant
//
//  Created by Rizal Hilman on 17/11/25.
//
import SwiftUI
import FoundationModels

struct TranscriptEntryView: View {
    let entry: Transcript.Entry

    var body: some View {
            switch entry {
            case .prompt(let prompt):
                if let text = extractText(from: prompt.segments), !text.isEmpty {
                    ChatBubble(message: ChatMessage(text: text, isUser: true))
                }
                
            case .response(let response):
                if let text = extractText(from: response.segments), !text.isEmpty {
                    ChatBubble(message: ChatMessage(text: text, isUser: false))
                }
                
            case .instructions:
                // Instructions are system-level and not part of user conversation flow
                EmptyView()
                
            @unknown default:
                EmptyView()
            }
        }
        
        private func extractText(from segments: [Transcript.Segment]) -> String? {
            let text = segments.compactMap { segment in
                if case .text(let textSegment) = segment {
                    return textSegment.content
                }
                return nil
            }.joined(separator: " ")
            
            return text.isEmpty ? nil : text
        }
}
