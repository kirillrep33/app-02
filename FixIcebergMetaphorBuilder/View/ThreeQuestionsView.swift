import SwiftUI


struct ThreeQuestionsView: View {
    @State private var firstAnswer: String = ""
    @State private var secondAnswer: String = ""
    @State private var thirdAnswer: String = ""
    @State private var deadlineText: String = ""
    @State private var isDeadlinePickerPresented: Bool = false
    @State private var selectedDeadline: Date = Date()

  
    @State private var isFirstExpanded: Bool = false
    @State private var isSecondExpanded: Bool = false
    @State private var isThirdExpanded: Bool = false

   
    let problemTitle: String
    let aboveItems: [String]
    let belowItems: [String]
    
    let existingItem: IcebergItem?
    
    var onFinished: (() -> Void)? = nil

    @EnvironmentObject private var router: AppRouter
    @EnvironmentObject private var store: IcebergStore
    @Environment(\.dismiss) private var dismiss

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

                            questionsSection(scale: scale)
                                .padding(.top, 24 * scale)
                                .padding(.horizontal, 16 * scale)

                            Spacer(minLength: 80 * scale)
                        }
                    }

                    VStack(spacing: 0) {
                        saveButtonSection(scale: scale)
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

               
                if isDeadlinePickerPresented {
                    DeadlinePickerSheet(
                        selectedDate: $selectedDeadline,
                        onSave: {
                            deadlineText = Self.deadlineFormatter.string(from: selectedDeadline)
                            isDeadlinePickerPresented = false
                        }
                    )
                    .transition(.move(edge: .bottom))
                }
            }
        }
        .onAppear {
            
            if let item = existingItem, firstAnswer.isEmpty && secondAnswer.isEmpty && thirdAnswer.isEmpty {
                firstAnswer = item.firstAnswer
                secondAnswer = item.secondAnswer
                thirdAnswer = item.thirdAnswer
                if let deadline = item.deadline {
                    selectedDeadline = deadline
                    deadlineText = Self.deadlineFormatter.string(from: deadline)
                }
            }
        }
    }

   

  
    private var areAllQuestionsAnswered: Bool {
        let t1 = firstAnswer.trimmingCharacters(in: .whitespacesAndNewlines)
        let t2 = secondAnswer.trimmingCharacters(in: .whitespacesAndNewlines)
        let t3 = thirdAnswer.trimmingCharacters(in: .whitespacesAndNewlines)
        return !t1.isEmpty && !t2.isEmpty && !t3.isEmpty
    }

   
    private static let deadlineFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd.MM.yy"
        return formatter
    }()

  

    private func headerSection(scale: CGFloat) -> some View {
        VStack(alignment: .leading, spacing: 6 * scale) {
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

                Text("Three Questions")
                    .font(.system(size: 28 * scale, weight: .bold))
                    .foregroundColor(.black)

                Spacer()
            }

            Text("Answer these questions to work through your iceberg")
                .font(.system(size: 10 * scale))
                .foregroundColor(Color.gray.opacity(0.8))
                .padding(.leading, 56 * scale)
        }
    }

    private func questionsSection(scale: CGFloat) -> some View {
        let allAnswered = areAllQuestionsAnswered

        return VStack(spacing: 16 * scale) {
            questionCard(
                scale: scale,
                title: "What can I control?",
                subtitle: "\"My words, my reaction, my action plan\"",
                answer: $firstAnswer,
                isExpanded: $isFirstExpanded,
                placeholder: "List the things you can control..."
            )

            questionCard(
                scale: scale,
                title: "What do I need to accept?",
                subtitle: "\"That other people may think differently, that the situation is not perfect\"",
                answer: $secondAnswer,
                isExpanded: $isSecondExpanded,
                placeholder: "Write what you need to accept..."
            )

            questionCard(
                scale: scale,
                title: "What is my first step?",
                subtitle: "\"Write a conversation plan, rest for 1 hour, talk to a friend\"",
                answer: $thirdAnswer,
                isExpanded: $isThirdExpanded,
                placeholder: "Describe your very first step..."
            )

          
            if allAnswered {
                deadlineSection(scale: scale)
            }
        }
    }

    private func questionCard(scale: CGFloat,
                              title: String,
                              subtitle: String,
                              answer: Binding<String>,
                              isExpanded: Binding<Bool>,
                              placeholder: String) -> some View {
       
        let isCompleted = !answer.wrappedValue.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
       
        let cardBackground = (isCompleted && !isExpanded.wrappedValue)
            ? Color(red: 214/255, green: 246/255, blue: 199/255)
            : Color.white

        return VStack(spacing: 0) {
            Button(action: {
                isExpanded.wrappedValue.toggle()
            }) {
                HStack {
                    VStack(alignment: .leading, spacing: 6 * scale) {
                        Text(title)
                            .font(.system(size: 18 * scale, weight: .semibold))
                            .foregroundColor(.black)

                        Text(subtitle)
                            .font(.system(size: 14 * scale))
                            .foregroundColor(Color.gray.opacity(0.8))
                            .lineLimit(nil)
                            .multilineTextAlignment(.leading)
                    }

                    Spacer()

                    Image(systemName: isExpanded.wrappedValue ? "chevron.up" : "chevron.down")
                        .font(.system(size: 16 * scale, weight: .semibold))
                        .foregroundColor(Color.gray.opacity(0.7))
                }
            }
            .buttonStyle(.plain)
            .buttonClickSound()

            if isExpanded.wrappedValue {
                ZStack(alignment: .topLeading) {
                    RoundedRectangle(cornerRadius: 20 * scale, style: .continuous)
                        .stroke(Color(red: 210/255, green: 220/255, blue: 245/255), lineWidth: 1 * scale)
                        .background(
                            RoundedRectangle(cornerRadius: 20 * scale, style: .continuous)
                                .fill(Color.white)
                        )

                    TextEditor(text: answer)
                        .font(.system(size: 14 * scale))
                        .foregroundColor(.black)
                        .padding(.horizontal, 12 * scale)
                        .padding(.vertical, 10 * scale)

                    if answer.wrappedValue.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                        Text(placeholder)
                            .font(.system(size: 14 * scale))
                            .foregroundColor(Color.gray.opacity(0.5))
                            .padding(.horizontal, 16 * scale)
                            .padding(.vertical, 12 * scale)
                    }
                }
                .frame(height: 120 * scale)
                .padding(.top, 12 * scale)

            }
        }
        .padding(.horizontal, 20 * scale)
        .padding(.vertical, 16 * scale)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 24 * scale, style: .continuous)
                .fill(cardBackground)
                .shadow(color: Color.black.opacity(0.06),
                        radius: 10 * scale,
                        x: 0,
                        y: 4 * scale)
        )
    }

  
    private func deadlineSection(scale: CGFloat) -> some View {
        Button(action: {
            isDeadlinePickerPresented = true
        }) {
            VStack(alignment: .leading, spacing: 8 * scale) {
                Text("Deadline (optional)")
                    .font(.system(size: 16 * scale, weight: .semibold))
                    .foregroundColor(.black)

                HStack {
                    Text(deadlineText.isEmpty ? "dd.mm.yy" : deadlineText)
                        .font(.system(size: 14 * scale))
                        .foregroundColor(deadlineText.isEmpty ? Color.gray.opacity(0.6) : .black)

                    Spacer()
                }
                .padding(.horizontal, 12 * scale)
                .frame(height: 40 * scale)
                .background(
                    RoundedRectangle(cornerRadius: 12 * scale, style: .continuous)
                        .stroke(Color(red: 210/255, green: 220/255, blue: 245/255),
                                lineWidth: 1 * scale)
                        .background(
                            RoundedRectangle(cornerRadius: 12 * scale, style: .continuous)
                                .fill(Color.white)
                        )
                )
            }
            .padding(.horizontal, 20 * scale)
            .padding(.top, 8 * scale)
        }
        .buttonStyle(.plain)
        .buttonClickSound()
    }



private struct DeadlinePickerSheet: View {
    @Binding var selectedDate: Date
    var onSave: () -> Void

    @State private var month: Int = Calendar.current.component(.month, from: Date())
    @State private var day: Int = Calendar.current.component(.day, from: Date())
    @State private var year: Int = Calendar.current.component(.year, from: Date())

    private let calendar = Calendar.current

    var body: some View {
        GeometryReader { geo in
            let width = geo.size.width
            let scale = width > 0 ? max(width / 393.0, 0.1) : 1.0

            VStack(spacing: 0) {
                Spacer()

                VStack(spacing: 8 * scale) {
                 
                    
                    VStack {
                        Text("Pick a time")
                            .font(.system(size: 17 * scale, weight: .medium))
                            .kerning(-0.43)
                            .foregroundColor(.black)
                    }
                    .frame(height: 44 * scale)
                    .frame(maxWidth: .infinity)
                    .padding(.horizontal, 10 * scale)
                    .overlay(
                        Rectangle()
                            .fill(Color(red: 186/255, green: 186/255, blue: 186/255))
                            .frame(height: 1),
                        alignment: .bottom
                    )

                   
                    HStack(spacing: 0) {
                     
                        Picker(selection: $month, label: EmptyView()) {
                            ForEach(1...12, id: \.self) { m in
                                Text(monthName(for: m))
                                    .font(.system(size: 17 * scale))
                                    .tag(m)
                            }
                        }
                        .pickerStyle(.wheel)
                        .frame(maxWidth: .infinity)
                        .clipped()

                     
                        Picker(selection: $day, label: EmptyView()) {
                            ForEach(1...daysInCurrentMonth, id: \.self) { d in
                                Text("\(d)")
                                    .font(.system(size: 17 * scale))
                                    .tag(d)
                            }
                        }
                        .pickerStyle(.wheel)
                        .frame(maxWidth: .infinity)
                        .clipped()

                        
                        Picker(selection: $year, label: EmptyView()) {
                            ForEach(yearRange, id: \.self) { y in
                                Text(String(format: "%d", y))
                                    .font(.system(size: 17 * scale))
                                    .tag(y)
                            }
                        }
                        .pickerStyle(.wheel)
                        .frame(maxWidth: .infinity)
                        .clipped()
                    }
                    .frame(height: 220 * scale)

                    
                    Button(action: onSave) {
                        Text("Save")
                            .font(.system(size: 16 * scale, weight: .bold))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .frame(height: 50 * scale)
                            .background(
                                RoundedRectangle(cornerRadius: 110 * scale, style: .continuous)
                                    .fill(Color(red: 52/255, green: 130/255, blue: 255/255))
                            )
                    }
                    .buttonStyle(.plain)
                    .buttonClickSound()
                    .padding(.horizontal, 16 * scale)
                    .frame(height: 50 * scale)
                }
                .padding(.horizontal, 16 * scale)
                .frame(width: width, height: 354 * scale)
                .background(Color(red: 237/255, green: 237/255, blue: 237/255))
                .cornerRadius(8 * scale, corners: [.topLeft, .topRight])
            }
            .edgesIgnoringSafeArea(.bottom)
            .onAppear {
               
                let components = calendar.dateComponents([.year, .month, .day], from: selectedDate)
                year = components.year ?? year
                month = components.month ?? month
                day = components.day ?? day
            }
            .onChange(of: month) { _ in
                normalizeAndUpdateDate()
            }
            .onChange(of: year) { _ in
                normalizeAndUpdateDate()
            }
            .onChange(of: day) { _ in
                normalizeAndUpdateDate()
            }
        }
    }

 

    private var daysInCurrentMonth: Int {
        let components = DateComponents(year: year, month: month)
        let date = calendar.date(from: components) ?? selectedDate
        return calendar.range(of: .day, in: .month, for: date)?.count ?? 31
    }

    private var yearRange: [Int] {
        let current = Calendar.current.component(.year, from: Date())
        
        return Array((current - 1)...(current + 3))
    }

    private func monthName(for month: Int) -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale.current
        return formatter.monthSymbols[month - 1]
    }

    private func normalizeAndUpdateDate() {
     
        let maxDay = daysInCurrentMonth
        if day > maxDay {
            day = maxDay
        }

        let components = DateComponents(year: year, month: month, day: day)
        if let date = calendar.date(from: components) {
            selectedDate = date
        }
    }
}


    private func saveButtonSection(scale: CGFloat) -> some View {
        let isEnabled = areAllQuestionsAnswered
        let backgroundColor = isEnabled
        ? Color(red: 52/255, green: 130/255, blue: 255/255)
        : Color.gray.opacity(0.35)

        return Button(action: {
            guard isEnabled else { return }

            let deadlineDate: Date?
            if deadlineText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                deadlineDate = nil
            } else {
                deadlineDate = selectedDeadline
            }

            if let item = existingItem {
                store.update(
                    item: item,
                    title: problemTitle,
                    aboveItems: aboveItems,
                    belowItems: belowItems,
                    firstAnswer: firstAnswer,
                    secondAnswer: secondAnswer,
                    thirdAnswer: thirdAnswer,
                    deadline: deadlineDate
                )
            } else {
                store.add(
                    title: problemTitle,
                    aboveItems: aboveItems,
                    belowItems: belowItems,
                    firstAnswer: firstAnswer,
                    secondAnswer: secondAnswer,
                    thirdAnswer: thirdAnswer,
                    deadline: deadlineDate
                )
            }

            onFinished?()
            dismiss()
        }) {
            Text("Save")
                .font(.system(size: 20 * scale, weight: .semibold))
                .foregroundColor(.white.opacity(0.9))
                .frame(maxWidth: .infinity)
                .frame(height: 45 * scale)
                .background(
                    RoundedRectangle(cornerRadius: 50 * scale, style: .continuous)
                        .fill(backgroundColor)
                )
        }
        .buttonStyle(.plain)
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
            }
            .padding(.horizontal, 40 * scale)
            .padding(.top, 10 * scale)
            .padding(.bottom, 6 * scale)
            .background(Color.white)
        }
    }
}


private extension View {
    func cornerRadius(_ radius: CGFloat, corners: UIRectCorner) -> some View {
        clipShape(RoundedCorner(radius: radius, corners: corners))
    }
}

private struct RoundedCorner: Shape {
    var radius: CGFloat = .infinity
    var corners: UIRectCorner = .allCorners

    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(
            roundedRect: rect,
            byRoundingCorners: corners,
            cornerRadii: CGSize(width: radius, height: radius)
        )
        return Path(path.cgPath)
    }
}

#Preview {
    ThreeQuestionsView(
        problemTitle: "Conflict at work",
        aboveItems: ["Shouted at the meeting"],
        belowItems: ["Fear of dismissal"],
        existingItem: nil
    )
}

