import SwiftUI

struct LoadingView: View {
    var body: some View {
        VStack(spacing: 12) {
            ProgressView()
            Text("Work in progress...")
                .font(.headline)
        }
        .padding()
    }
}
