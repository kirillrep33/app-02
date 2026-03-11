import SwiftUI

/// Корневой SwiftUI‑контейнер, который управляет онбордингом и вкладками Archive/Stats.
struct RootView: View {
    @StateObject private var router = AppRouter()
    @StateObject private var store = IcebergStore()
    @State private var didFinishOnboarding: Bool = false

    var body: some View {
        Group {
            if didFinishOnboarding {
                // Основные вкладки приложения
                switch router.selectedTab {
                case .archive:
                    IcebergArchiveView()
                case .stats:
                    StatisticsView()
                }
            } else {
                // Онбординг – по завершении переключаемся на основную часть
                OnboardingView(onFinish: {
                    didFinishOnboarding = true
                })
            }
        }
        .environmentObject(router)
        .environmentObject(store)
    }
}

#Preview {
    RootView()
}

