import SwiftUI

struct UserInfoInputView: View {
    @Environment(AppCoordinator.self) private var coordinator

    var body: some View {
        VStack(spacing: 32) {
            Spacer()

            Text("ユーザー情報入力")
                .font(.title.bold())

            Text("（仮）")
                .foregroundStyle(.secondary)

            Spacer()

            Button {
                coordinator.navigateToCamera()
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
        .navigationTitle("ユーザー情報")
    }
}
