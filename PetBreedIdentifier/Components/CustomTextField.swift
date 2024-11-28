import SwiftUI

struct CustomTextField: View {
    let placeholder: String
    @Binding var text: String
    var isSecure: Bool = false
    
    var body: some View {
        Group {
            if isSecure {
                SecureField(placeholder, text: $text) .frame(height: 40)
                    .customTextFieldStyle()
                    .autocapitalization(.none)
                   
            } else {
                TextField(placeholder, text: $text)    .frame(height: 40)
                    .customTextFieldStyle()
                    .autocapitalization(.none)
                
            }
        }
    }
}
