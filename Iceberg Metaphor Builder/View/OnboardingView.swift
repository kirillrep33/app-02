import SwiftUI

/// Онбординг из трёх экранов с картинками `onboarding1/2/3`.
/// После последнего экрана открывается `IcebergArchiveView`.
struct OnboardingView: View {
    @State private var currentPage: Int = 0
    /// Коллбек, который вызывается после завершения онбординга.
    /// В корневом `RootView` он переключает приложение на основную часть.
    var onFinish: (() -> Void)? = nil

    var body: some View {
        TabView(selection: $currentPage) {
            OnboardingPageView(
                imageName: "onboarding1",
                title: "Break the Surface",
                subtitle: "Create your iceberg and separate visible symptoms from hidden causes. Understand what lies beneath the surface.",
                buttonTitle: "Next"
            ) {
                withAnimation(.easeInOut) {
                    currentPage = 1
                }
            }
            .tag(0)

            OnboardingPageView(
                imageName: "onboarding2",
                title: "Discover What’s Hidden",
                subtitle: "Answer guiding questions and uncover emotions, beliefs and deeper reasons behind the problem.",
                buttonTitle: "Next"
            ) {
                withAnimation(.easeInOut) {
                    currentPage = 2
                }
            }
            .tag(1)

            OnboardingPageView(
                imageName: "onboarding3",
                title: "See Your Progress",
                subtitle: "Track solved problems, review past insights and watch your understanding grow.",
                buttonTitle: "Get Started"
            ) {
                withAnimation(.easeInOut) {
                    onFinish?()
                }
            }
            .tag(2)
        }
        .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
        .ignoresSafeArea(edges: .top)
    }
}

/// Один экран онбординга, общая верстка и логика.
private struct OnboardingPageView: View {
    let imageName: String
    let title: String
    let subtitle: String
    let buttonTitle: String
    let onButtonTap: () -> Void

    var body: some View {
        GeometryReader { geometry in
            VStack(spacing: 0) {
 
                Image(imageName)
                    .resizable()
                    .scaledToFill()
                    .frame(width: geometry.size.width,
                           height: geometry.size.height * 0.65)
                    .clipped()
                    .clipShape(BottomRoundedRectangle(cornerRadius: 40))
                    .padding(.horizontal, 16)
                    .ignoresSafeArea(edges: .top)

                VStack(spacing: 16) {
                    Text(title)
                        .font(.system(size: 24, weight: .semibold))
                        .foregroundColor(Color(red: 0/255, green: 87/255, blue: 255/255))
                        .multilineTextAlignment(.center)
                        .minimumScaleFactor(0.9)

                    Text(subtitle)
                        .font(.system(size: 16, weight: .regular))
                        .foregroundColor(.black)
                        .multilineTextAlignment(.center)
                        .minimumScaleFactor(0.9)
                }
                .padding(.horizontal, 32)

                Spacer()

                Button(action: onButtonTap) {
                    Text(buttonTitle)
                        .font(.system(size: 20, weight: .semibold))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(
                            RoundedRectangle(cornerRadius: 28, style: .continuous)
                                .fill(Color(red: 0/255, green: 122/255, blue: 255/255))
                        )
                }
                .buttonClickSound()
                .padding(.horizontal, 32)
                .padding(.bottom, 24 + geometry.safeAreaInsets.bottom)
            }
            
            .frame(width: geometry.size.width, height: geometry.size.height)
            .background(Color.white)
            
        }
        
    }
}

#Preview {
    OnboardingView()
}

