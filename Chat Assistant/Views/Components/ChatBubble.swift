//
//  ChatBubble.swift
//  Chat Assistant
//
//  Created by Rizal Hilman on 17/11/25.
//
import SwiftUI

// MARK: - Chat Bubble
struct ChatBubble: View {
    let message: ChatMessage

    var body: some View {
        HStack {
            if message.isUser { Spacer(minLength: 40) }

            Text(message.text)
                .font(.system(size: 16))
                .foregroundStyle(message.isUser ? .white : .primary)
                .padding(.vertical, 10)
                .padding(.horizontal, 14)
                .background(
                    RoundedRectangle(cornerRadius: 18, style: .continuous)
                        .fill(message.isUser ? Color.black : Color(.systemGray6))
                )
                .frame(maxWidth: 280, alignment: message.isUser ? .trailing : .leading)

            if !message.isUser { Spacer(minLength: 40) }
        }
        .frame(maxWidth: .infinity, alignment: message.isUser ? .trailing : .leading)
        .animation(.default, value: message.text)
    }
}
