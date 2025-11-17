//
//  ChatView.swift
//  Chat Assistant
//
//  Created by Rizal Hilman on 17/11/25.
//

import SwiftUI

struct ChatView: View {
    @State private var message: String = ""
    @State private var messages: [ChatMessage] = [
        ChatMessage(text: "Hi there! How can I help you today?", isUser: false),
        ChatMessage(text: "Add sample bubble chat message", isUser: true),
        ChatMessage(text: "Here's a sample bubble layout using SwiftUI.", isUser: false)
    ]
    @FocusState private var isInputFocused: Bool

    var body: some View {
        ZStack(alignment: .top) {
            // Main scrollable area with auto-scroll to bottom
            ScrollViewReader { proxy in
                ScrollView {
                    VStack(alignment: .leading, spacing: 0) {
                        // Sample chat bubbles
                        VStack(spacing: 12) {
                            ForEach(messages) { msg in
                                ChatBubble(message: msg)
                                    .id(msg.id)
                            }
                        }
                        .padding(.top, 16)
                        .padding(.horizontal, 20)
                        .padding(.bottom, 16)
                    }
                    .contentShape(Rectangle())
                    .onTapGesture {
                        isInputFocused = false
                    }
                }
                .scrollDismissesKeyboard(.interactively)
                .onAppear {
                    if let last = messages.last {
                        proxy.scrollTo(last.id, anchor: .bottom)
                    }
                }
                .onChange(of: messages) { _ in
                    // Ensure we always scroll to the latest message, even when content exceeds the device height
                    if let last = messages.last {
                        withAnimation(.easeOut) {
                            proxy.scrollTo(last.id, anchor: .bottom)
                        }
                    }
                }
            }

            if messages.isEmpty {
                VStack(spacing: 12) {
                    Spacer()
                    suggestionRow
                        .padding(.horizontal, 8)
                }
                .padding(.bottom, 6)
                .transition(.move(edge: .bottom).combined(with: .opacity))
            }
        }
        .background(Color(.systemBackground))
        .safeAreaInset(edge: .top) {
            header
                .padding(.horizontal, 20)
                .padding(.top, 12)
                .background(Color(.systemBackground))
        }
        .safeAreaInset(edge: .bottom) { composer }
        .navigationBarHidden(true)
    }

    // MARK: - Header
    private var header: some View {
        HStack(spacing: 12) {
            HStack(spacing: 4) {
                Text("Chat")
                    .font(.system(size: 24, weight: .semibold))
                Text("Assistant")
                    .font(.system(size: 24, weight: .regular))
                    .foregroundStyle(.secondary)
            }
            Spacer()

            Button(action: {
                withAnimation(.easeInOut) {
                    messages.removeAll()
                }
            }) {
                Image(systemName: "trash")
                    .font(.system(size: 14, weight: .semibold))
                    .frame(width: 28, height: 28)
                    .foregroundStyle(.secondary)
                    .background(
                        Circle()
                            .stroke(style: StrokeStyle(lineWidth: 2, dash: [5]))
                    )
            }
            .buttonStyle(.plain)
            .accessibilityLabel("Clear chat")
        }
    }

    // MARK: - Suggestion Row
    private var suggestionRow: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 16) {
                SuggestionCard(title: "Creative ways", subtitle: "to teach coding to kids")
                SuggestionCard(title: "Generate UI", subtitle: "for a finance tracking app")
            }
            .padding(.horizontal, 2)
        }
    }

    // MARK: - Composer
    private var composer: some View {
        VStack(spacing: 12) {
            HStack(spacing: 12) {

                // Input field with mic icon
                HStack(spacing: 10) {
                    TextField("Ask anything", text: $message, axis: .vertical)
                        .focused($isInputFocused)
                        .textFieldStyle(.plain)
                        .font(.system(size: 18))
                        .padding(.vertical, 12)

                    Button(action: {}) {
                        Image(systemName: "mic")
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundStyle(.secondary)
                    }
                    .buttonStyle(.plain)
                }
                .padding(.horizontal, 14)
                .background(
                    RoundedRectangle(cornerRadius: 28, style: .continuous)
                        .fill(Color(.systemGray6))
                )

                // Send button
                Button(action: {
                    let trimmed = message.trimmingCharacters(in: .whitespacesAndNewlines)
                    guard !trimmed.isEmpty else { return }
                    messages.append(ChatMessage(text: trimmed, isUser: true))
                    message = ""
                    isInputFocused = false
                }) {
                    Image(systemName: "paperplane.fill")
                        .font(.system(size: 18, weight: .bold))
                        .foregroundStyle(.white)
                        .frame(width: 44, height: 44)
                        .background(
                            Circle().fill(!message.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? Color.black : Color(.systemGray4))
                        )
                }
                .buttonStyle(.plain)
                .disabled(message.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                .accessibilityLabel("Send message")
            }
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 10)
    }
}


#Preview {
    NavigationStack {
        ChatView()
    }
}
