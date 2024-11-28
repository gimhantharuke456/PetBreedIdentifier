import SwiftUI

struct CustomButton: View {
    let title: String
    let action: () -> Void
    var isDisabled: Bool = false
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .customButtonStyle(isDisabled: isDisabled)
        }
        .disabled(isDisabled)
    }
}
