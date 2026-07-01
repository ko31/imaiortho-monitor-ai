import SwiftUI

struct TopView: View {
    @Environment(AppCoordinator.self) private var coordinator

    var body: some View {
        VStack(spacing: 32) {
            Spacer()

            Text("MonitorAI")
                .font(.largeTitle.bold())

            Text("（TOP画面 - 仮）")
                .foregroundStyle(.secondary)

            Spacer()

            Button {
                coordinator.navigateToUserInfo()
            } label: {
                Text("次へ")
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(.blue)
                    .foregroundStyle(.white)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
            }
            .padding(.horizontal, 40)
            .padding(.bottom, 40)
        }
        .navigationTitle("")
        .navigationBarHidden(true)
    }
}
