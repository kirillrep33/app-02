import SwiftUI


struct CreateIcebergView: View {
    @State private var problemText: String = ""
    @State private var aboveItems: [String] = [""]
    @State private var belowItems: [String] = [""]
    @State private var showThreeQuestions: Bool = false

    @EnvironmentObject private var router: AppRouter
    @EnvironmentObject private var store: IcebergStore
    @Environment(\.dismiss) private var dismiss

    
    let existingItem: IcebergItem?

    var onFinished: (() -> Void)? = nil

    init(existingItem: IcebergItem? = nil, onFinished: (() -> Void)? = nil) {
        self.existingItem = existingItem
        self.onFinished = onFinished

        if let item = existingItem {
            _problemText = State(initialValue: item.title)
            _aboveItems = State(initialValue: item.aboveItems.isEmpty ? [""] : item.aboveItems)
            _belowItems = State(initialValue: item.belowItems.isEmpty ? [""] : item.belowItems)
        } else {
            _problemText = State(initialValue: "")
            _aboveItems = State(initialValue: [""])
            _belowItems = State(initialValue: [""])
        }
    }

    var body: some View {
        GeometryReader { geo in
            let width = geo.size.width
            let scale = width > 0 ? max(width / 393.0, 0.1) : 1.0

            ZStack {

                LinearGradient(
                    gradient: Gradient(colors: [
                        Color(red: 239/255, green: 246/255, blue: 255/255),
                        Color.white
                    ]),
                    startPoint: .top,
                    endPoint: .bottom
                )
                .ignoresSafeArea()

                VStack(spacing: 0) {
                    ScrollView(.vertical, showsIndicators: false) {
                        VStack(alignment: .leading, spacing: 0) {
                            headerSection(scale: scale)
                                .padding(.top, 18 * scale)
                                .padding(.horizontal, 24 * scale)

                            problemSection(scale: scale)
                                .padding(.top, 24 * scale)
                                .padding(.horizontal, 24 * scale)

                            icebergPanelSection(scale: scale)
                                .padding(.top, 24 * scale)
                       
                                .frame(maxWidth: .infinity, alignment: .center)

                            Spacer(minLength: 120 * scale)
                        }
                    }

           
                    VStack(spacing: 0) {
                        continueButtonSection(scale: scale)
                            .padding(.horizontal, 24 * scale)
                            .padding(.top, 12 * scale)
                            .padding(.bottom, 8 * scale)

                        bottomTabBar(scale: scale)
                            .padding(.bottom, max(geo.safeAreaInsets.bottom, 6 * scale))
                    }

                    .shadow(color: Color.black.opacity(0.05),
                            radius: 8 * scale,
                            x: 0,
                            y: -4 * scale)
                }
                .ignoresSafeArea(edges: .bottom)
                .fullScreenCover(isPresented: $showThreeQuestions) {
                    ThreeQuestionsView(
                        problemTitle: problemText,
                        aboveItems: aboveItems,
                        belowItems: belowItems,
                        existingItem: existingItem,
                        onFinished: {
                           
                            onFinished?()
                            dismiss()
                        }
                    )
                    .environmentObject(router)
                    .environmentObject(store)
                }
            }
        }
    }

  

   
    private var areAllPanelsFilled: Bool {
        let trimmedAbove = aboveItems.map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
        let trimmedBelow = belowItems.map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
        return !trimmedAbove.contains(where: { $0.isEmpty }) &&
               !trimmedBelow.contains(where: { $0.isEmpty })
    }

  

    private func headerSection(scale: CGFloat) -> some View {
        HStack(spacing: 16 * scale) {
            Button {
                dismiss()
            } label: {
                ZStack {
                    Circle()
                        .fill(Color(red: 52/255, green: 130/255, blue: 255/255))
                        .shadow(color: Color.black.opacity(0.1),
                                radius: 3 * scale,
                                x: 0,
                                y: 1 * scale)
                    Image("ArrowLeft")
                        .resizable()
                        .frame(width: 20 * scale, height: 20 * scale)
                        .foregroundColor(.white)
                }
               
                .frame(width: 40 * scale, height: 40 * scale)
            }
            .buttonStyle(.plain)
            .buttonClickSound()

            Text(existingItem == nil ? "Create Iceberg" : "Edit Iceberg")
                .font(.system(size: 24 * scale, weight: .medium))
                .foregroundColor(.black)

            Spacer()
        }
    }

    private func problemSection(scale: CGFloat) -> some View {
        VStack(alignment: .leading, spacing: 10 * scale) {
            Text("Problem")
                .font(.system(size: 16 * scale, weight: .semibold))
                .foregroundColor(.black)

            ZStack(alignment: .leading) {
                TextField("",
                          text: $problemText)
                    .font(.system(size: 12 * scale))
                    .padding(.horizontal, 12 * scale)
                  
                    .frame(height: 34 * scale)
                    .background(
                        RoundedRectangle(cornerRadius: 10 * scale, style: .continuous)
                            .stroke(Color(red: 52/255, green: 130/255, blue: 255/255).opacity(0.2), lineWidth: 1 * scale)
                            .background(
                                RoundedRectangle(cornerRadius: 10 * scale, style: .continuous)
                                    .fill(Color.white)
                            )
                    )
                
                if problemText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                    Text("Describe your problem or situation...")
                        .font(.system(size: 12 * scale))
                        .foregroundColor(Color.gray.opacity(0.5))
                        .padding(.horizontal, 12 * scale)
                        .allowsHitTesting(false)
                }
            }
        }
    }

  
    private func icebergPanelSection(scale: CGFloat) -> some View {
        VStack(spacing: 0) {
            aboveWaterSection(scale: scale)
                .frame(maxWidth: .infinity, alignment: .topLeading)
                .padding(.bottom, 24 * scale)
                .background(Color.white)

            belowWaterSection(scale: scale)
                .frame(maxWidth: .infinity, alignment: .topLeading)
                .padding(.vertical, 24 * scale)
                .background(
                    LinearGradient(
                        gradient: Gradient(colors: [
                            Color(red: 81/255, green: 162/255, blue: 255/255),
                            Color(red: 21/255, green: 93/255, blue: 252/255)
                        ]),
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
        }
        .background(
            RoundedRectangle(cornerRadius: 20 * scale, style: .continuous)
                .stroke(Color(red: 52/255, green: 130/255, blue: 255/255).opacity(0.2),
                        lineWidth: 1 * scale)
                .background(
                    RoundedRectangle(cornerRadius: 20 * scale, style: .continuous)
                        .fill(Color.white)
                )
        )
        .clipShape(RoundedRectangle(cornerRadius: 20 * scale, style: .continuous))
       
        .frame(width: 327 * scale)
        .shadow(color: Color.black.opacity(0.25),
                radius: 4 * scale,
                x: 0,
                y: 1 * scale)
    }

  
    private func aboveWaterSection(scale: CGFloat) -> some View {
        VStack(alignment: .leading, spacing: 0) {
            VStack(alignment: .leading, spacing: 8 * scale) {
                VStack(alignment: .leading, spacing: 4 * scale) {
                    Text("Above Water 🌊")
                        .font(.system(size: 16 * scale, weight: .semibold))
                        .foregroundColor(.black)

                    Text("What others see / External manifestations")
                        .font(.system(size: 13 * scale))
                        .foregroundColor(Color.black.opacity(0.5))
                }
              
                .frame(width: 255 * scale, alignment: .leading)

                ForEach(aboveItems.indices, id: \.self) { index in
                    HStack(spacing: 8 * scale) {
                        ZStack(alignment: .leading) {
                            TextField("", text: $aboveItems[index])
                                .font(.system(size: 12 * scale))
                                .padding(.horizontal, 12 * scale)
                              
                                .frame(width: 270 * scale, height: 34 * scale, alignment: .leading)
                                .background(
                                    RoundedRectangle(cornerRadius: 10 * scale, style: .continuous)
                                        .stroke(Color(red: 52/255, green: 130/255, blue: 255/255).opacity(0.2), lineWidth: 1 * scale)
                                        .background(
                                            RoundedRectangle(cornerRadius: 10 * scale, style: .continuous)
                                                .fill(Color.white)
                                        )
                                )
                            
                            if aboveItems[index].trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                                Text("Enter what others see...")
                                    .font(.system(size: 12 * scale))
                                    .foregroundColor(Color.gray.opacity(0.5))
                                    .padding(.horizontal, 12 * scale)
                                    .allowsHitTesting(false)
                            }
                        }

                       
                        if index > 0 {
                            Button {
                                aboveItems.remove(at: index)
                            } label: {
                                Image(systemName: "xmark.circle.fill")
                                    .resizable()
                                    .foregroundColor(Color.gray.opacity(0.5))
                                    .frame(width: 14 * scale, height: 14 * scale)
                            }
                            .buttonStyle(.plain)
                            .buttonClickSound()
                        }
                    }
                    .padding(.top, index == 0 ? 0 : 8 * scale)
                }
            }
            .padding(.top, 20 * scale)

            Button(action: {
                aboveItems.append("")
            }) {
                Text("+ Add item")
                    .font(.system(size: 14 * scale, weight: .bold))
                    .foregroundColor(.white)
                 
                    .frame(width: 238 * scale, height: 34 * scale)
                    .background(
                        RoundedRectangle(cornerRadius: 60 * scale, style: .continuous)
                            .fill(Color(red: 26/255, green: 115/255, blue: 232/255))
                    )
            }
            .buttonStyle(.plain)
            .buttonClickSound()
            .padding(.top, 12 * scale)
        }
       
        .padding(.leading, 28 * scale)
    }

   
    private func belowWaterSection(scale: CGFloat) -> some View {
        VStack(alignment: .leading, spacing: 0) {
            VStack(alignment: .leading, spacing: 8 * scale) {
                VStack(alignment: .leading, spacing: 4 * scale) {
                    Text("Below Water 🧊")
                        .font(.system(size: 16 * scale, weight: .semibold))
                        .foregroundColor(.white)

                    Text("What you feel / True causes")
                        .font(.system(size: 13 * scale))
                        .foregroundColor(Color.white.opacity(0.9))
                }
              
                .frame(width: 170 * scale, alignment: .leading)

                ForEach(belowItems.indices, id: \.self) { index in
                    HStack(spacing: 8 * scale) {
                        ZStack(alignment: .leading) {
                            TextField("", text: $belowItems[index])
                                .font(.system(size: 12 * scale))
                                .foregroundColor(.white)
                                .padding(.horizontal, 12 * scale)
                               
                                .frame(width: 270 * scale, height: 34 * scale, alignment: .leading)
                                .background(
                                    RoundedRectangle(cornerRadius: 10 * scale, style: .continuous)
                                        .stroke(Color.white, lineWidth: 1 * scale)
                                        .background(
                                            LinearGradient(
                                                gradient: Gradient(colors: [
                                                    Color(red: 81/255, green: 162/255, blue: 255/255),
                                                    Color(red: 21/255, green: 93/255, blue: 252/255)
                                                ]),
                                                startPoint: .top,
                                                endPoint: .bottom
                                            )
                                            .clipShape(
                                                RoundedRectangle(cornerRadius: 10 * scale, style: .continuous)
                                            )
                                        )
                                )
                            
                            if belowItems[index].trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                                Text("Enter what you feel...")
                                    .font(.system(size: 12 * scale))
                                    .foregroundColor(Color.white.opacity(0.6))
                                    .padding(.horizontal, 12 * scale)
                                    .allowsHitTesting(false)
                            }
                        }

                        if index > 0 {
                            Button {
                                belowItems.remove(at: index)
                            } label: {
                                Image(systemName: "xmark.circle.fill")
                                    .resizable()
                                    .foregroundColor(Color.white.opacity(0.7))
                                    .frame(width: 14 * scale, height: 14 * scale)
                            }
                            .buttonStyle(.plain)
                            .buttonClickSound()
                        }
                    }
                    .padding(.top, index == 0 ? 0 : 8 * scale)
                }
            }
            .padding(.top, 20 * scale)

            Button(action: {
                belowItems.append("")
            }) {
                Text("+ Add item")
                    .font(.system(size: 14 * scale, weight: .bold))
                    .foregroundColor(Color(red: 26/255, green: 115/255, blue: 232/255))
                 
                    .frame(width: 238 * scale, height: 34 * scale)
                    .background(
                        RoundedRectangle(cornerRadius: 60 * scale, style: .continuous)
                            .fill(Color.white)
                    )
            }
            .buttonStyle(.plain)
            .buttonClickSound()
            .padding(.top, 12 * scale)
        }
        
        .padding(.leading, 28 * scale)
    }

    private func continueButtonSection(scale: CGFloat) -> some View {
        let isEnabled = areAllPanelsFilled
        let backgroundColor = isEnabled
        ? Color(red: 52/255, green: 130/255, blue: 255/255)
        : Color.gray.opacity(0.35)

        return Button(action: {
            guard isEnabled else { return }
            showThreeQuestions = true
        }) {
            Text("Continue to Questions")
                .font(.system(size: 20 * scale, weight: .bold))
                .foregroundColor(.white.opacity(0.9))
                .frame(maxWidth: .infinity)
             
                .frame(height: 50 * scale)
                .background(
                    RoundedRectangle(cornerRadius: 60 * scale, style: .continuous)
                        .fill(backgroundColor)
                )
        }
        .buttonStyle(.plain)
        .buttonClickSound()
    }

    private func bottomTabBar(scale: CGFloat) -> some View {
        VStack(spacing: 0) {
          
            Rectangle()
                .fill(Color(red: 187/255, green: 212/255, blue: 255/255))
                .frame(height: 1 * scale)

            HStack {
               
                Button {
                    router.selectedTab = .archive
                } label: {
                    VStack(spacing: 4 * scale) {
                        Image("1-on")
                            .resizable()
                            .frame(width: 22 * scale, height: 22 * scale)
                        Text("Archive")
                            .font(.system(size: 13 * scale))
                    }
                    .foregroundColor(Color(red: 26/255, green: 115/255, blue: 232/255))
                    .frame(maxWidth: .infinity)
                }
                .buttonStyle(.plain)
                .buttonClickSound()

              
                Button {
                    router.selectedTab = .stats
                } label: {
                    VStack(spacing: 4 * scale) {
                        Image("2-off")
                            .resizable()
                            .frame(width: 22 * scale, height: 22 * scale)

                        Text("Stats")
                            .font(.system(size: 13 * scale))
                    }
                    .foregroundColor(Color.gray.opacity(0.4))
                    .frame(maxWidth: .infinity)
                }
                .buttonStyle(.plain)
                .buttonClickSound()
            }
            .padding(.horizontal, 40 * scale)
            .padding(.top, 10 * scale)
            .padding(.bottom, 6 * scale)
            .background(Color.white)
        }

    }
}



#Preview {
    CreateIcebergView()
}

