//
//  Created by Alex.M on 14.06.2022.
//

import SwiftUI

struct TextInputView: View {

    @Environment(\.chatTheme) private var theme

    @EnvironmentObject private var globalFocusState: GlobalFocusState

    @Binding var text: String
    var inputFieldId: UUID
    var style: InputViewStyle
    var availableInput: AvailableInputType
    let trailingPadding: CGFloat = 16
    let leadingPadding: CGFloat = 8

    var body: some View {
        TextField("", text: $text, axis: .vertical)
            .customFocus($globalFocusState.focus, equals: .uuid(inputFieldId))
            .placeholder(when: text.isEmpty) {
                Text(style.placeholder)
                    .foregroundColor(theme.colors.buttonBackground)
            }
            .foregroundColor(style == .message ? theme.colors.textLightContext : theme.colors.textDarkContext)
            .padding(.vertical, 10)
            .padding(.leading, leadingPadding)
            .padding(.trailing, trailingPadding)
            // .padding(.leading, !availableInput.isMediaAvailable ? 12 : 0)
            .onTapGesture {
                globalFocusState.focus = .uuid(inputFieldId)
            }
    }
}
