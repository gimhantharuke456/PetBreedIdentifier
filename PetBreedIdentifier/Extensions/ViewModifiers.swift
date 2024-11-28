import SwiftUI

extension View {
    func customTextFieldStyle() -> some View {
        self
            .padding(10)
            .background(Color.gray.opacity(0.2)) // Lighter gray background
            .foregroundColor(.gray.opacity(0.8)) // Darker gray text
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(Color.orange, lineWidth: 2)
            )
         
            .cornerRadius(8)
    }
    
    func customTextAreaStyle() -> some View {
        self
            .padding(10)
            .background(Color.gray.opacity(0.2)) // Lighter gray background
            .foregroundColor(.gray.opacity(0.8)) // Darker gray text
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(Color.orange, lineWidth: 2)
            )
            .cornerRadius(8)
    }
    
    func customButtonStyle(isDisabled: Bool = false) -> some View {
        self
            .frame(maxWidth: .infinity)
            .padding()
            .background(isDisabled ? Color.gray : Color.orange) // Orange button
            .foregroundColor(.white) // White text
            .cornerRadius(8)
            .font(.headline)
    }
}
