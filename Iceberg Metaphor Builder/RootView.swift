import SwiftUI


struct RootView: View {
    @StateObject private var router = AppRouter()
    @StateObject private var store = IcebergStore()
    @State private var didFinishOnboarding: Bool = false

    var body: some View {
        Group {
            if didFinishOnboarding {
             
                switch router.selectedTab {
                case .archive:
                    IcebergArchiveView()
                case .stats:
                    StatisticsView()
                }
            } else {
               
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

