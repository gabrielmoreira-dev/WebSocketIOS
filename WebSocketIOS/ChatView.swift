import SwiftUI

struct ChatView: View {
    private let viewModel: ChatViewModel

    init(viewModel: ChatViewModel = ChatViewModel()) {
        self.viewModel = viewModel
    }

    var body: some View {
        VStack {
            Button("Close") {
                viewModel.close()
            }
        }
        .padding()
        .onAppear {
            viewModel.setUp()
        }
    }
}

#Preview {
    ChatView()
}
