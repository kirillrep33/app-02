import SwiftUI


struct BottomRoundedRectangle: Shape {
    var cornerRadius: CGFloat = 40

    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(
            roundedRect: rect,
            byRoundingCorners: [.bottomLeft, .bottomRight],
            cornerRadii: CGSize(width: cornerRadius, height: cornerRadius)
        )
        return Path(path.cgPath)
    }
}

struct OnboardingFirstView: View {
    var body: some View {
        GeometryReader { geometry in
            VStack(spacing: 0) {
                
                Image("onboarding1")
                    .resizable()
                    .scaledToFill()
                    .frame(width: geometry.size.width,
                           height: geometry.size.height * 0.65)
                    .clipped()
                    .clipShape(BottomRoundedRectangle(cornerRadius: 40))
                    .padding(.horizontal, 16)
                    .ignoresSafeArea(edges: .top)

                VStack(spacing: 16) {
                    Text("Break the Surface")
                        .font(.system(size: 24, weight: .semibold))
                        .foregroundColor(Color(red: 0/255, green: 87/255, blue: 255/255))
                        .multilineTextAlignment(.center)
                        .minimumScaleFactor(0.9)

                    Text("Create your iceberg and separate visible symptoms from hidden causes. Understand what lies beneath the surface.")
                        .font(.system(size: 18, weight: .regular))
                        .foregroundColor(Color.black.opacity(0.8))
                        .multilineTextAlignment(.center)
                        .minimumScaleFactor(0.9)
                }
                .padding(.horizontal, 32)
                

                Spacer()

                Button(action: {
              
                }) {
                    Text("Next")
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

struct OnboardingFirstView_Previews: PreviewProvider {
    static var previews: some View {
        OnboardingFirstView()
    }
}

