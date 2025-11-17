//
//  ChatView.swift
//  Chat Assistant
//
//  Created by Rizal Hilman on 17/11/25.
//

import SwiftUI
import Foundation
import Combine

struct ChatView: View {
    @StateObject private var viewModel = ChatViewModel()
    @FocusState private var isInputFocused: Bool

    var body: some View {
        ZStack(alignment: .top) {
            ScrollViewReader { proxy in
                ScrollView {
                    VStack(alignment: .leading, spacing: 0) {
                        // Sample chat bubbles
                        VStack(spacing: 12) {
                            ForEach(viewModel.messages) { msg in
                                ChatBubble(message: msg)
                                    .id(msg.id)
                            }
                            
                            // Loading indicator
                            if viewModel.isLoading {
                                HStack {
                                    HStack(spacing: 8) {
                                        ProgressView()
                                            .scaleEffect(0.8)
                                        Text("Thinking...")
                                            .font(.system(size: 14))
                                            .foregroundStyle(.secondary)
                                    }
                                    .padding(.horizontal, 16)
                                    .padding(.vertical, 12)
                                    .background(
                                        RoundedRectangle(cornerRadius: 20, style: .continuous)
                                            .fill(Color(.systemGray6))
                                    )
                                    
                                    Spacer()
                                }
                                .id("loading")
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
                    if let last = viewModel.messages.last {
                        proxy.scrollTo(last.id, anchor: .bottom)
                    }
                }
                .onChange(of: viewModel.messages) { _ in
                    // Ensure we always scroll to the latest message, even when content exceeds the device height
                    if let last = viewModel.messages.last {
                        withAnimation(.easeOut) {
                            proxy.scrollTo(last.id, anchor: .bottom)
                        }
                    }
                }
                .onChange(of: viewModel.isLoading) { isLoading in
                    if isLoading {
                        withAnimation(.easeOut) {
                            proxy.scrollTo("loading", anchor: .bottom)
                        }
                    }
                }
            }

            if viewModel.messages.isEmpty {
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
                viewModel.clearChat()
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
                SuggestionCard(
                    title: "Creative ways", 
                    subtitle: "to teach coding to kids"
                ) {
                    viewModel.handleSuggestion("Creative ways", subtitle: "to teach coding to kids")
                }
                
                SuggestionCard(
                    title: "Generate UI", 
                    subtitle: "for a finance tracking app"
                ) {
                    viewModel.handleSuggestion("Generate UI", subtitle: "for a finance tracking app")
                }
            }
            .padding(.horizontal, 2)
        }
    }

    // MARK: - Composer
    private var composer: some View {
        VStack(spacing: 12) {
            HStack(spacing: 12) {
                HStack(spacing: 10) {
                    TextField("Ask anything", text: $viewModel.message, axis: .vertical)
                        .focused($isInputFocused)
                        .textFieldStyle(.plain)
                        .font(.system(size: 18))
                        .padding(.vertical, 12)
                        .onChange(of: isInputFocused) { focused in
                            viewModel.isInputFocused = focused
                        }
                        .onChange(of: viewModel.isInputFocused) { focused in
                            isInputFocused = focused
                        }
                }
                .padding(.horizontal, 14)
                .glassEffect(.regular.interactive(), in: .rect(cornerRadius: 28))

                // Send button
                Button(action: {
                    viewModel.sendMessage()
                }) {
                    Image(systemName: "paperplane.fill")
                        .font(.system(size: 18, weight: .bold))
                        .frame(width: 40, height: 38)
                }
                .buttonStyle(.glassProminent)
                .disabled(!viewModel.canSendMessage)
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
