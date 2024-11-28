import SwiftUI

struct CustomTextArea: View {
    let placeholder: String
    @Binding var text: String
    
    var body: some View {
        ZStack(alignment: .topLeading) {
            if text.isEmpty {
                Text(placeholder)
                    .foregroundColor(.red.opacity(0.7))
                    .padding(8)
            }
            
            TextEditor(text: $text)
                .frame(minHeight: 100)
                .customTextAreaStyle()
        }
    }
}

