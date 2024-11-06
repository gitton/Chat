//
//  InputView.swift
//  Chat
//
//  Created by Alex.M on 25.05.2022.
//

import SwiftUI
import ExyteMediaPicker

public enum InputViewStyle {
    case message
    case signature

    var placeholder: String {
        switch self {
        case .message:
            return "Type a message..."
        case .signature:
            return "Add signature..."
        }
    }
}

public enum InputViewAction {
    case photo
    case add
    case camera
    case send

    case saveEdit
    case cancelEdit
}

public enum InputViewState {
    case empty
    case hasTextOrMedia

    case editing

    var canSend: Bool {
        switch self {
        case .hasTextOrMedia: return true
        default: return false
        }
    }
}

public enum AvailableInputType {
    case full // media + text
    case textAndMedia
    case textOnly

    var isMediaAvailable: Bool {
        [.full, .textAndMedia].contains(self)
    }
}

public struct InputViewAttachments {
    public var medias: [Media] = []
    public var replyMessage: ReplyMessage?
}

struct InputView: View {

    @Environment(\.chatTheme) private var theme
    @Environment(\.mediaPickerTheme) private var pickerTheme

    @ObservedObject var viewModel: InputViewModel
    var inputFieldId: UUID
    var style: InputViewStyle
    var availableInput: AvailableInputType
    var messageUseMarkdown: Bool
    @Binding var loading: Bool

    
    private var onAction: (InputViewAction) -> Void {
        viewModel.inputViewAction()
    }

    private var state: InputViewState {
        viewModel.state
    }

    @State private var overlaySize: CGSize = .zero

    var body: some View {
        VStack {
            viewOnTop
            HStack(alignment: .bottom, spacing: 10) {
                HStack(alignment: .bottom, spacing: 0) {
                    // leftView commented out to hide the attachment button
                    middleView
                }
                .background {
                    RoundedRectangle(cornerRadius: 18)
                        .fill(fieldBackgroundColor)
                }

                rightOutsideButton
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
        }
        .background(backgroundColor)
    }

    @ViewBuilder
    var leftView: some View {
        switch style {
        case .message:
            if availableInput.isMediaAvailable {
                attachButton
            }
        case .signature:
            if viewModel.mediaPickerMode == .cameraSelection {
                addButton
            } else {
                Color.clear.frame(width: 12, height: 1)
            }
        }
    }

    @ViewBuilder
    var middleView: some View {
        TextInputView(text: $viewModel.text, inputFieldId: inputFieldId, style: style, availableInput: availableInput)
            .frame(minHeight: 48)
    }

    @ViewBuilder
    var editingButtons: some View {
        HStack {
            Button {
                onAction(.cancelEdit)
            } label: {
                Image(systemName: "xmark")
                    .foregroundStyle(.white)
                    .fontWeight(.bold)
                    .padding(5)
                    .background(Circle().foregroundStyle(.red))
            }

            Button {
                onAction(.saveEdit)
            } label: {
                Image(systemName: "checkmark")
                    .foregroundStyle(.white)
                    .fontWeight(.bold)
                    .padding(5)
                    .background(Circle().foregroundStyle(.green))
            }
        }
    }

    @ViewBuilder
    var rightOutsideButton: some View {
        if state == .editing {
            editingButtons
                .frame(height: 48)
        } else {
            if loading {
                LottieView(name: "processing")
                    .frame(width: 60, height: 36)
            } else {
                sendButton
                    .disabled(!state.canSend)
                    .frame(width: 48, height: 48)
            }
        }
    }

    @ViewBuilder
    var viewOnTop: some View {
        if let message = viewModel.attachments.replyMessage {
            VStack(spacing: 8) {
                Rectangle()
                    .foregroundColor(theme.colors.friendMessage)
                    .frame(height: 2)

                HStack {
                    theme.images.reply.replyToMessage
                    Capsule()
                        .foregroundColor(theme.colors.myMessage)
                        .frame(width: 2)
                    VStack(alignment: .leading) {
                        Text("Reply to \(message.user.name)")
                            .font(.caption2)
                            .foregroundColor(theme.colors.buttonBackground)
                        if !message.text.isEmpty {
                            textView(message.text)
                                .font(.caption2)
                                .lineLimit(1)
                                .foregroundColor(theme.colors.textLightContext)
                        }
                    }
                    .padding(.vertical, 2)

                    Spacer()

                    if let first = message.attachments.first {
                        AsyncImageView(url: first.thumbnail)
                            .viewSize(30)
                            .cornerRadius(4)
                            .padding(.trailing, 16)
                    }

                    theme.images.reply.cancelReply
                        .onTapGesture {
                            viewModel.attachments.replyMessage = nil
                        }
                }
                .padding(.horizontal, 26)
            }
            .fixedSize(horizontal: false, vertical: true)
        }
    }

    @ViewBuilder
    func textView(_ text: String) -> some View {
        if messageUseMarkdown,
           let attributed = try? AttributedString(markdown: text) {
            Text(attributed)
        } else {
            Text(text)
        }
    }

    var attachButton: some View {
        Button {
            onAction(.photo)
        } label: {
            theme.images.inputView.attach
                .viewSize(24)
                .padding(EdgeInsets(top: 12, leading: 12, bottom: 12, trailing: 8))
        }
    }

    var addButton: some View {
        Button {
            onAction(.add)
        } label: {
            theme.images.inputView.add
                .viewSize(24)
                .circleBackground(theme.colors.addButtonBackground)
                .padding(EdgeInsets(top: 12, leading: 12, bottom: 12, trailing: 8))
        }
    }

    var cameraButton: some View {
        Button {
            onAction(.camera)
        } label: {
            theme.images.inputView.attachCamera
                .viewSize(24)
                .padding(EdgeInsets(top: 12, leading: 8, bottom: 12, trailing: 12))
        }
    }

    var sendButton: some View {
        Button {
            onAction(.send)
        } label: {
            theme.images.inputView.arrowSend
                .viewSize(48)
                .circleBackground(theme.colors.sendButtonBackground)
        }
    }

    var fieldBackgroundColor: Color {
        switch style {
        case .message:
            return theme.colors.inputLightContextBackground
        case .signature:
            return theme.colors.inputDarkContextBackground
        }
    }

    var backgroundColor: Color {
        switch style {
        case .message:
            return theme.colors.mainBackground
        case .signature:
            return pickerTheme.main.albumSelectionBackground
        }
    }
}
