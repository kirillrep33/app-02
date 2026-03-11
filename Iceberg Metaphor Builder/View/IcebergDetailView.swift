import SwiftUI
import UIKit

/// Детальный экран проблемы "Conflict at work".
/// Верстка максимально повторяет предоставленный макет 390×844,
/// все размеры и отступы масштабируются от ширины экрана через `scale`.
struct IcebergDetailView: View {
    let item: IcebergItem
    @EnvironmentObject private var router: AppRouter
    @EnvironmentObject private var store: IcebergStore
    @Environment(\.dismiss) private var dismiss
    @State private var isEditing: Bool = false
    @State private var isEditingSolutionNote: Bool = false
    @State private var solutionNoteDraft: String = ""
    @State private var localSolutionNote: String? = nil
    @State private var shareImage: UIImage? = nil

    var body: some View {
        GeometryReader { geo in
            let width = geo.size.width
            let scale = width > 0 ? max(width / 390.0, 0.1) : 1.0

            ZStack {
                // Фон экрана
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
                                .padding(.top, 20 * scale)

                            statusSection(scale: scale)
                                .padding(.top, 20 * scale)

                            icebergCardsSection(scale: scale)
                                .padding(.top, 36 * scale)
                                .frame(maxWidth: .infinity, alignment: .center)

                            qaSection(scale: scale)
                                .padding(.top, 36 * scale)

                            solutionNoteSection(scale: scale)
                                .padding(.top, 24 * scale)

                            metaInfoSection(scale: scale)
                                .padding(.top, 28 * scale)

                            exportButton(scale: scale)
                                .padding(.top, 24 * scale)

                            Spacer(minLength: 40 * scale)
                        }
                        .padding(.horizontal, 20 * scale)
                    }

                    detailBottomBar(scale: scale)
                        .padding(.bottom, max(geo.safeAreaInsets.bottom, 0))
                }
                .ignoresSafeArea(edges: .bottom)
                .onAppear {
                    localSolutionNote = item.solutionNote
                }
                .sheet(item: $shareImage) { image in
                    ActivityView(activityItems: [image])
                }
                .fullScreenCover(isPresented: $isEditing) {
                    CreateIcebergView(existingItem: item, onFinished: {
                        isEditing = false
                        dismiss()
                    })
                    .environmentObject(router)
                    .environmentObject(store)
                }
            }
        }
    }

    // MARK: - Header

    private func headerSection(scale: CGFloat) -> some View {
        ZStack {
            HStack {
                Button(action: {
                    dismiss()
                }) {
                    backButton(scale: scale)
                }
                .buttonStyle(.plain)
                .buttonClickSound()
                
                Text(item.title)
                    .font(.system(size: 24 * scale, weight: .medium))
                    .foregroundColor(.black)
                Spacer()

            }



            HStack(spacing: 12 * scale) {
                Spacer()
                Button {
                    isEditing = true
                } label: {
                    editButton(scale: scale)
                }
                .buttonStyle(.plain)
                .buttonClickSound()

                Button {
                    store.remove(item)
                    dismiss()
                } label: {
                    deleteButton(scale: scale)
                }
                .buttonStyle(.plain)
                .buttonClickSound()
            }
        }
        .frame(height: 40 * scale)
    }

    private func backButton(scale: CGFloat) -> some View {
        ZStack {
            Circle()
                .fill(Color(red: 52/255, green: 130/255, blue: 255/255))
                .frame(width: 40 * scale, height: 40 * scale)
                .shadow(color: Color.black.opacity(0.15),
                        radius: 4 * scale,
                        x: 0,
                        y: 2 * scale)

            Image("ArrowLeft")
                .resizable()
                .frame(width: 20 * scale, height: 20 * scale)
                .foregroundColor(.white)
        }
    }

    private func editButton(scale: CGFloat) -> some View {
        ZStack {
            Circle()
                .fill(
                    LinearGradient(
                        gradient: Gradient(colors: [
                            Color(red: 81/255, green: 162/255, blue: 255/255),
                            Color(red: 21/255, green: 93/255, blue: 252/255)
                        ]),
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                .frame(width: 40 * scale, height: 40 * scale)

            Image("edit")
                .resizable()
                .frame(width: 23 * scale, height: 23 * scale)
                .foregroundColor(.white)
        }
    }

    private func deleteButton(scale: CGFloat) -> some View {
        ZStack {
            Circle()
                .fill(Color(red: 1.0, green: 77/255, blue: 77/255))
                .frame(width: 40 * scale, height: 40 * scale)

            Image("delete")
                .resizable()
                .frame(width: 23 * scale, height: 23 * scale)
                .foregroundColor(.white)
        }
    }

    // MARK: - Status section

    private func statusSection(scale: CGFloat) -> some View {
        VStack(alignment: .leading, spacing: 8 * scale) {
            Text("Status")
                .font(.system(size: 16 * scale, weight: .medium))
                .foregroundColor(.black)

            HStack(spacing: 8 * scale) {
                statusChip(
                    title: "🟡 In Progress",
                    isActive: item.status == .inProgress,
                    width: 119 * scale,
                    scale: scale
                )

                statusChip(
                    title: "🟢 Solved",
                    isActive: item.status == .solved,
                    width: 88 * scale,
                    scale: scale
                )

                statusChip(
                    title: "🔴 Not Solved",
                    isActive: item.status == .notSolved,
                    width: 116 * scale,
                    scale: scale
                )
            }
        }
    }

    private func statusChip(
        title: String,
        isActive: Bool,
        width: CGFloat,
        scale: CGFloat
    ) -> some View {
        Text(title)
            .font(.system(size: 14 * scale, weight: .medium))
            .frame(width: width, height: 38 * scale)
            .background(
                Capsule(style: .continuous)
                    .fill(isActive ? Color(red: 52/255, green: 130/255, blue: 255/255) : Color.white)
            )
            .overlay(
                Capsule(style: .continuous)
                    .stroke(Color(red: 210/255, green: 210/255, blue: 210/255),
                            lineWidth: 0.3 * scale)
            )
            .foregroundColor(isActive ? .white : Color(red: 52/255, green: 130/255, blue: 255/255))
    }

    // MARK: - Above / Below water cards

    private func icebergCardsSection(scale: CGFloat) -> some View {
        VStack(spacing: 0) {
            // Верхняя половина карточки: белый фон, скругление только по верхним углам
            VStack(alignment: .leading, spacing: 8 * scale) {
                Text("Above Water 🌊")
                    .font(.system(size: 16 * scale, weight: .medium))
                    .foregroundColor(.black)

                ForEach(item.aboveItems.filter { !$0.isEmpty }, id: \.self) { aboveItem in
                    Text("• \(aboveItem)")
                        .font(.system(size: 13 * scale, weight: .medium))
                        .foregroundColor(.black)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, 28 * scale)
            .padding(.vertical, 14 * scale)
            .background(Color.white)

            // Нижняя половина карточки: синий градиент, скругление только по нижним углам
            VStack(alignment: .leading, spacing: 8 * scale) {
                Text("Below Water 🧊")
                    .font(.system(size: 16 * scale, weight: .medium))
                    .foregroundColor(.white)

                ForEach(item.belowItems.filter { !$0.isEmpty }, id: \.self) { belowItem in
                    Text("• \(belowItem)")
                        .font(.system(size: 13 * scale, weight: .medium))
                        .foregroundColor(.white)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, 28 * scale)
            .padding(.vertical, 14 * scale)
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
        // Общая карточка с единым скруглением краёв и без скругления в месте стыка панелей.
        // Высота растёт от контента (как в CreateIcebergView), минимальная визуально ~166pt.
        .frame(width: 327 * scale)
        .background(
            RoundedRectangle(cornerRadius: 20 * scale, style: .continuous)
                .fill(Color.white)
        )
        .clipShape(RoundedRectangle(cornerRadius: 20 * scale, style: .continuous))
        .shadow(color: Color.black.opacity(0.25),
                radius: 4 * scale,
                x: 0,
                y: 1 * scale)
    }

    // MARK: - Q&A section

    @State private var isQASectionExpanded: Bool = false
    
    private func qaSection(scale: CGFloat) -> some View {
        VStack(alignment: .leading, spacing: 12 * scale) {
            // Заголовок панели
            Button(action: {
                isQASectionExpanded.toggle()
            }) {
                ZStack {
                    RoundedRectangle(cornerRadius: 25 * scale, style: .continuous)
                        .fill(Color(red: 52/255, green: 130/255, blue: 255/255).opacity(0.2))

                    HStack {
                        Text("Questions & Answers")
                            .font(.system(size: 16 * scale, weight: .medium))
                            .foregroundColor(.black)

                        Spacer()

                        Image(systemName: isQASectionExpanded ? "chevron.down" : "chevron.up")
                            .font(.system(size: 12 * scale, weight: .semibold))
                            .foregroundColor(.black)
                    }
                    .padding(.horizontal, 20 * scale)
                }
                .frame(width: 350 * scale, height: 43 * scale)
            }
            .buttonStyle(.plain)
            .buttonClickSound()
            
            // Развёрнутая часть
            if isQASectionExpanded {
                VStack(alignment: .leading, spacing: 4 * scale) {
                    if !item.firstAnswer.isEmpty {
                        VStack(alignment: .leading, spacing: 4 * scale) {
                            Text("What can I control?")
                                .font(.system(size: 14 * scale, weight: .semibold))
                                .foregroundColor(.black)
                            Text(item.firstAnswer)
                                .font(.system(size: 13 * scale))
                                .foregroundColor(.black)
                        }
                    }
                    
                    if !item.secondAnswer.isEmpty {
                        VStack(alignment: .leading, spacing: 4 * scale) {
                            Text("What do I need to accept?")
                                .font(.system(size: 14 * scale, weight: .semibold))
                                .foregroundColor(.black)
                            Text(item.secondAnswer)
                                .font(.system(size: 13 * scale))
                                .foregroundColor(.black)
                        }
                    }
                    
                    if !item.thirdAnswer.isEmpty {
                        VStack(alignment: .leading, spacing: 4 * scale) {
                            Text("What is my first step?")
                                .font(.system(size: 14 * scale, weight: .semibold))
                                .foregroundColor(.black)
                            Text(item.thirdAnswer)
                                .font(.system(size: 13 * scale))
                                .foregroundColor(.black)
                        }
                    }
                    
                    if let deadline = item.deadline {
                        Text("Deadline: \(DateFormatter.localizedString(from: deadline, dateStyle: .medium, timeStyle: .none))")
                            .font(.system(size: 13 * scale))
                            .foregroundColor(.black)
                    }
                }
                .frame(width: 350 * scale, alignment: .leading)
            }
        }
    }

    // MARK: - Solution Note

    private func solutionNoteSection(scale: CGFloat) -> some View {
        VStack(alignment: .leading, spacing: 8 * scale) {
            HStack {
                Text("Solution Note")
                    .font(.system(size: 16 * scale, weight: .medium))
                    .foregroundColor(.black)

                Spacer()

                Button {
                    // Открываем редактор заметки, подставляя существующий текст (если есть)
                    solutionNoteDraft = localSolutionNote ?? ""
                    isEditingSolutionNote = true
                } label: {
                    Text("Edit")
                        .font(.system(size: 14 * scale, weight: .medium))
                        .foregroundColor(Color(red: 52/255, green: 130/255, blue: 255/255))
                }
                .buttonStyle(.plain)
                .buttonClickSound()
            }

            if isEditingSolutionNote {
                // Панель ввода Solution Note по макету
                VStack(alignment: .leading, spacing: 12 * scale) {
                    ZStack(alignment: .topLeading) {
                        RoundedRectangle(cornerRadius: 20 * scale, style: .continuous)
                            .fill(Color.white)
                            .overlay(
                                RoundedRectangle(cornerRadius: 20 * scale, style: .continuous)
                                    .stroke(Color(red: 52/255, green: 130/255, blue: 255/255).opacity(0.2),
                                            lineWidth: 1 * scale)
                            )
                            .frame(width: 350 * scale, height: 101 * scale)

                        TextEditor(text: $solutionNoteDraft)
                            .font(.system(size: 12 * scale))
                            .foregroundColor(.black)
                            .padding(.horizontal, 16 * scale)
                            .padding(.vertical, 10 * scale)
                            .frame(width: 350 * scale, height: 101 * scale)
                            .background(Color.clear)

                        if solutionNoteDraft.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                            Text("What helped? What didn't work? Any insights?")
                                .font(.system(size: 12 * scale))
                                .foregroundColor(Color(red: 143/255, green: 143/255, blue: 143/255))
                                .padding(.horizontal, 16 * scale)
                                .padding(.top, 12 * scale)
                        }
                    }

                    Button {
                        let trimmed = solutionNoteDraft.trimmingCharacters(in: .whitespacesAndNewlines)
                        localSolutionNote = trimmed.isEmpty ? nil : trimmed
                        store.updateSolutionNote(for: item, note: trimmed.isEmpty ? nil : trimmed)
                        isEditingSolutionNote = false
                    } label: {
                        Text("Save Solution Note")
                            .font(.system(size: 20 * scale, weight: .bold))
                            .foregroundColor(.white)
                            .frame(width: 350 * scale, height: 50 * scale)
                            .background(
                                RoundedRectangle(cornerRadius: 60 * scale, style: .continuous)
                                    .fill(Color(red: 52/255, green: 130/255, blue: 255/255))
                            )
                    }
                    .buttonStyle(.plain)
                    .buttonClickSound()
                }
            } else if let note = localSolutionNote, !note.isEmpty {
                // Отображаем сохранённую заметку под заголовком
                Text(note)
                    .font(.system(size: 12 * scale, weight: .regular))
                    .foregroundColor(Color(red: 143/255, green: 143/255, blue: 143/255))
                    .lineSpacing(2 * scale)
            }
        }
    }

    // MARK: - Meta info

    private func metaInfoSection(scale: CGFloat) -> some View {
        VStack(alignment: .leading, spacing: 12 * scale) {
            metaRow(
                title: "Created:",
                value: DateFormatter.localizedString(from: item.createdAt, dateStyle: .medium, timeStyle: .none),
                scale: scale
            )
            metaRow(
                title: "Updated:",
                value: DateFormatter.localizedString(from: item.updatedAt, dateStyle: .medium, timeStyle: .none),
                scale: scale
            )
            if let deadline = item.deadline {
                metaRow(
                    title: "Deadline:",
                    value: DateFormatter.localizedString(from: deadline, dateStyle: .medium, timeStyle: .none),
                    scale: scale
                )
            }
        }
    }

    private func metaRow(title: String, value: String, scale: CGFloat) -> some View {
        HStack {
            Text(title)
                .font(.system(size: 14 * scale, weight: .medium))
                .foregroundColor(Color(red: 143/255, green: 143/255, blue: 143/255))

            Spacer()

            Text(value)
                .font(.system(size: 14 * scale, weight: .regular))
                .foregroundColor(Color(red: 143/255, green: 143/255, blue: 143/255))
        }
    }

    // MARK: - Export button

    private func exportButton(scale: CGFloat) -> some View {
        Button(action: {
            captureScreenContent()
        }) {
            ZStack {
                RoundedRectangle(cornerRadius: 60 * scale, style: .continuous)
                    .fill(Color(red: 52/255, green: 130/255, blue: 255/255).opacity(0.2))

                HStack(spacing: 8 * scale) {
                    Image(systemName: "square.and.arrow.up")
                        .font(.system(size: 16 * scale, weight: .semibold))
                        .foregroundColor(Color(red: 52/255, green: 130/255, blue: 255/255))

                    Text("Export")
                        .font(.system(size: 20 * scale, weight: .bold))
                        .foregroundColor(Color(red: 52/255, green: 130/255, blue: 255/255))
                }
            }
            .frame(height: 50 * scale)
        }
        .buttonStyle(.plain)
        .buttonClickSound()
    }
    
    private func captureScreenContent() {
        // Небольшая задержка для завершения анимаций
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                  let window = windowScene.windows.first else {
                print("❌ Failed to get window")
                return
            }
            
            // Захватываем весь экран окна
            let bounds = window.bounds
            let renderer = UIGraphicsImageRenderer(bounds: bounds)
            
            // Используем drawHierarchy для более точного захвата
            let image = renderer.image { context in
                window.drawHierarchy(in: bounds, afterScreenUpdates: false)
            }
            
            // Проверяем, что изображение создано и не пустое
            guard image.size.width > 0 && image.size.height > 0 else {
                print("❌ Captured image is empty")
                return
            }
            
            print("✅ Image captured successfully: \(image.size)")
            shareImage = image
        }
    }

    // MARK: - Bottom bar

    private func detailBottomBar(scale: CGFloat) -> some  View {
        VStack(spacing: 0) {
            // Тонкая синяя линия сверху
            Rectangle()
                .fill(Color(red: 187/255, green: 212/255, blue: 255/255))
                .frame(height: 1 * scale)

            HStack {
                // Левая вкладка Archive
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

                // Правая вкладка Stats
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

// MARK: - ActivityView for sharing PNG

private struct ActivityView: UIViewControllerRepresentable {
    let activityItems: [Any]

    func makeUIViewController(context: Context) -> UIActivityViewController {
        print("📤 Creating ActivityView with \(activityItems.count) items")
        
        let controller = UIActivityViewController(activityItems: activityItems, applicationActivities: nil)
        
        // Настройка для iPad (popover)
        if let popover = controller.popoverPresentationController {
            if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
               let window = windowScene.windows.first {
                popover.sourceView = window
                popover.sourceRect = CGRect(
                    x: window.bounds.midX,
                    y: window.bounds.midY,
                    width: 0,
                    height: 0
                )
                popover.permittedArrowDirections = []
            }
        }
        
        // Обработчик завершения для отладки
        controller.completionWithItemsHandler = { activityType, completed, returnedItems, error in
            if let error = error {
                print("❌ ActivityView error: \(error)")
            } else {
                print("✅ ActivityView completed: \(completed), type: \(String(describing: activityType))")
            }
        }
        
        return controller
    }

    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}

// MARK: - UIImage Identifiable Extension

extension UIImage: Identifiable {
    public var id: ObjectIdentifier {
        ObjectIdentifier(self)
    }
}

// MARK: - Preview

#Preview {
    IcebergDetailView(item: IcebergItem(
        title: "Conflict at work",
        aboveItems: ["Shouted at the meeting"],
        belowItems: ["Fear of dismissal"],
        status: .inProgress,
        firstAnswer: "My words, my reaction, my action plan",
        secondAnswer: "That other people may think differently",
        thirdAnswer: "Write a conversation plan"
    ))
    .environmentObject(AppRouter())
}

