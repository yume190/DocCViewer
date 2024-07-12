import SwiftUI

struct LoadingViewModifier: ViewModifier {
    @Binding var isLoading: Bool
    
    func body(content: Content) -> some View {
        ZStack {
            content
                .disabled(isLoading) // Disable interaction when loading
                .blur(radius: isLoading ? 3 : 0) // Blur the background when loading
            
            if isLoading {
                VStack {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle())
                        .scaleEffect(2)
                    Text("Loading...")
                        .font(.headline)
                        .padding(.top, 10)
                }
                .frame(width: 150, height: 150)
                .background(Color.primary.colorInvert())
                .foregroundColor(Color.primary)
                .cornerRadius(10)
                .shadow(radius: 10)
            }
        }
    }
}

extension View {
    func loadingHUD(isLoading: Binding<Bool>) -> some View {
        self.modifier(LoadingViewModifier(isLoading: isLoading))
    }
}
