//
//  ChatBubble.swift
//  Chat Assistant
//
//  Created by Rizal Hilman on 17/11/25.
//
import SwiftUI
import MarkdownUI

struct ChatBubble: View {
    let message: ChatMessage

    var body: some View {
        HStack {
            if message.isUser { Spacer() }
            Markdown(message.text)
                .font(.system(size: 16))
                .foregroundStyle(message.isUser ? .white : .primary)
                .markdownTextStyle(textStyle: {
                    ForegroundColor(message.isUser ? .white : .primary)
                })
                .tint(message.isUser ? .white : .accentColor)
                .padding(.vertical, 10)
                .padding(.horizontal, 14)
                .background(
                    RoundedRectangle(cornerRadius: 18, style: .continuous)
                        .fill(message.isUser ? Color.accentColor : Color(.systemGray6))
                )
                .frame(maxWidth: 280, alignment: message.isUser ? .trailing : .leading)
            if !message.isUser { Spacer() }
        }
        .frame(maxWidth: .infinity)
        .animation(.default, value: message.text)
    }
}

