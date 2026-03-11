import SwiftUI

/// Фильтр для статуса записей.
enum FilterStatus {
    case all
    case inProgress
    case solved
    case notSolved
}

/// Главный экран "Iceberg Archive".
/// Пока без логики и навигации — только верстка, которая масштабируется по ширине экрана через GeometryReader.
struct IcebergArchiveView: View {
    let isEmpty: Bool

    @EnvironmentObject private var store: IcebergStore
    @EnvironmentObject private var router: AppRouter

    @State private var isPresentingCreate: Bool = false
    @State private var selectedFilter: FilterStatus = .all
    @State private var selectedItem: IcebergItem? = nil
    @State private var searchText: String = ""

    init(empty: Bool = true) {
        self.isEmpty = empty
    }
    
    /// Отфильтрованные записи в зависимости от выбранного фильтра.
    private var filteredItems: [IcebergItem] {
        // Сначала фильтрация по статусу
        let statusFiltered: [IcebergItem] = {
            switch selectedFilter {
            case .all:
                return store.items
            case .inProgress:
                return store.items.filter { $0.status == .inProgress }
            case .solved:
                return store.items.filter { $0.status == .solved }
            case .notSolved:
                return store.items.filter { $0.status == .notSolved }
            }
        }()

        // Затем — по строке поиска (по заголовку и Above/Below)
        let query = searchText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !query.isEmpty else { return statusFiltered }

        let lowered = query.lowercased()
        return statusFiltered.filter { item in
            if item.title.lowercased().contains(lowered) {
                return true
            }
            if item.aboveItems.contains(where: { $0.lowercased().contains(lowered) }) {
                return true
            }
            if item.belowItems.contains(where: { $0.lowercased().contains(lowered) }) {
                return true
            }
            return false
        }
    }

    var body: some View {
        GeometryReader { geo in
            let width = geo.size.width
            // Базовый коэффициент от ширины iPhone 15 Pro (примерно 393pt)
            let scale = width > 0 ? max(width / 393.0, 0.1) : 1.0

            NavigationStack {
                ZStack {
                    // Фон
                    Color(red: 244/255, green: 248/255, blue: 255/255)

                    VStack(spacing: 0) {
                        // Верхний контент
                        ScrollView(.vertical, showsIndicators: false) {
                            VStack(alignment: .leading, spacing: 0) {
                                headerSection(scale: scale)
                                    .padding(.top, 24 * scale)

                                filterChipsSection(scale: scale)
                                    .padding(.top, 20 * scale)

                                searchBarSection(scale: scale)
                                    .padding(.top, 20 * scale)

                                Spacer(minLength: 24 * scale)

                                if filteredItems.isEmpty {
                                    emptyStateSection(scale: scale, availableHeight: geo.size.height)
                                        .padding(.bottom, 80 * scale)
                                } else {
                                    problemsListSection(scale: scale)
                                        .padding(.top, 4 * scale)
                                        .padding(.bottom, 80 * scale)
                                }
                            }
                            .padding(.horizontal, 24 * scale)
                        }

                        // Нижняя вкладочная панель
                        bottomTabBar(scale: scale)
                            .padding(.bottom, max(geo.safeAreaInsets.bottom, 8 * scale))
                            .background(
                                Color.white
                                    .shadow(color: Color.black.opacity(0.05),
                                            radius: 6 * scale,
                                            x: 0,
                                            y: -2 * scale)
                            )
                    }
                    // VStack должен игнорировать safe area только снизу
                    .ignoresSafeArea(edges: .bottom)
                    .fullScreenCover(isPresented: $isPresentingCreate) {
                        CreateIcebergView(onFinished: {
                            isPresentingCreate = false
                        })
                        .environmentObject(router)
                        .environmentObject(store)
                    }
                    .fullScreenCover(item: $selectedItem) { item in
                        IcebergDetailView(item: item)
                            .environmentObject(router)
                            .environmentObject(store)
                    }
                }
            }
        }
    }

    // MARK: - Sections

    private func headerSection(scale: CGFloat) -> some View {
        VStack(alignment: .leading, spacing: 6 * scale) {
            Text("Iceberg Archive")
                .font(.system(size: 34 * scale, weight: .bold, design: .rounded))
                .foregroundColor(Color.black)

            Text("See what's hidden. Solve what matters.")
                .font(.system(size: 16 * scale, weight: .regular))
                .foregroundColor(Color.black.opacity(0.6))
        }
    }

    private func filterChipsSection(scale: CGFloat) -> some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12 * scale) {
                filterChip(title: "All",
                           color: Color.blue,
                           filter: .all,
                           scale: scale)

                filterChip(title: "In Progress",
                           color: Color.yellow,
                           filter: .inProgress,
                           scale: scale)

                filterChip(title: "Solved",
                           color: Color.green,
                           filter: .solved,
                           scale: scale)

                filterChip(title: "Not Solved",
                           color: Color.red,
                           filter: .notSolved,
                           scale: scale)
            }
            // Внутренние отступы, чтобы первая и последняя кнопка не подрезались
            .padding(.horizontal, 2 * scale)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private func searchBarSection(scale: CGFloat) -> some View {
        HStack(spacing: 8 * scale) {
            Image(systemName: "magnifyingglass")
                .foregroundColor(Color.gray.opacity(0.7))

            TextField("Search problems...", text: $searchText)
                .foregroundColor(.black)
                .font(.system(size: 16 * scale))
                .disableAutocorrection(true)

            if !searchText.isEmpty {
                Button(action: {
                    searchText = ""
                }) {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(Color.gray.opacity(0.6))
                        .font(.system(size: 16 * scale))
                }
                .buttonStyle(.plain)
                .buttonClickSound()
            }
        }
        .padding(.horizontal, 16 * scale)
        .frame(height: 44 * scale)
        .background(
            RoundedRectangle(cornerRadius: 16 * scale, style: .continuous)
                .fill(Color.white)
                .shadow(color: Color.black.opacity(0.05),
                        radius: 6 * scale,
                        x: 0,
                        y: 2 * scale)
        )
    }

    // Секция со списком проблем (две карточки, как на скриншоте)
    private func problemsListSection(scale: CGFloat) -> some View {
        VStack(spacing: 20 * scale) {
            ForEach(filteredItems) { item in
                let status = statusInfo(for: item.status)

                SwipeableProblemCard(
                    scale: scale,
                    title: item.title,
                    statusTitle: status.title,
                    statusColor: status.color,
                    createdDate: DateFormatter.localizedString(from: item.createdAt, dateStyle: .medium, timeStyle: .none),
                    updatedDate: DateFormatter.localizedString(from: item.updatedAt, dateStyle: .medium, timeStyle: .none),
                    onSetNotSolved: { store.updateStatus(for: item, to: .notSolved) },
                    onSetInProgress: { store.updateStatus(for: item, to: .inProgress) },
                    onSetSolved: { store.updateStatus(for: item, to: .solved) },
                    onDelete: { store.remove(item) },
                    onTap: { selectedItem = item }
                )
            }
        }
    }

    private func statusInfo(for status: IcebergStatus) -> (title: String, color: Color) {
        switch status {
        case .inProgress:
            return ("In Progress", .yellow)
        case .solved:
            return ("Solved", .green)
        case .notSolved:
            return ("Not Solved", .red)
        }
    }

    private func emptyStateSection(scale: CGFloat, availableHeight: CGFloat) -> some View {
        VStack(spacing: 20 * scale) {
            Image("ice")
                .resizable()
                .scaledToFit()
                .frame(width: 96 * scale, height: 96 * scale)

            VStack(spacing: 4 * scale) {
                Text("No icebergs yet")
                    .font(.system(size: 20 * scale, weight: .semibold))
                    .foregroundColor(Color(red: 52/255, green: 130/255, blue: 255/255))
                    .frame(maxWidth: .infinity)

                Text("Create your first iceberg to get started")
                    .font(.system(size: 14 * scale, weight: .regular))
                    .foregroundColor(Color.black)
                    .frame(maxWidth: .infinity)
            }
            .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .frame(minHeight: availableHeight * 0.4)
    }

    private func bottomTabBar(scale: CGFloat) -> some View {
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

                // Центральная круглая кнопка "+"
                Button {
                    isPresentingCreate = true
                } label: {
                    ZStack {
                        Circle()
                            .fill(Color(red: 26/255, green: 115/255, blue: 232/255))
                            .frame(width: 44 * scale, height: 44 * scale)

                        Image(systemName: "plus")
                            .foregroundColor(.white)
                            .font(.system(size: 20 * scale, weight: .bold))
                    }
                }
                .buttonStyle(.plain)
                .buttonClickSound()
                .frame(maxWidth: .infinity)

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

    // MARK: - Subviews

    private func filterChip(title: String,
                            color: Color,
                            filter: FilterStatus,
                            scale: CGFloat) -> some View {
        let isSelected = selectedFilter == filter
        let isAll = filter == .all
        
        return Button(action: {
            selectedFilter = filter
        }) {
            HStack(spacing: isAll ? 0 : 8 * scale) {
                if !isAll {
                    Circle()
                        .fill(color)
                        .frame(width: 14 * scale, height: 14 * scale)
                }
                
                Text(title)
                    .font(.system(size: 15 * scale, weight: .semibold))
                    .foregroundColor(isSelected ? .white : Color(red: 26/255, green: 115/255, blue: 232/255))
                    .multilineTextAlignment(.center)
            }
            .frame(maxWidth: .infinity)
            .padding(.horizontal, 16 * scale)
            .padding(.vertical, 10 * scale)
            .background(
                Capsule(style: .continuous)
                    .fill(isSelected ? Color.blue : Color.white)
            )
            .overlay(
                Capsule(style: .continuous)
                    .stroke(isSelected ? Color.clear : Color.gray.opacity(0.25),
                            lineWidth: 1 * scale)
            )
            .foregroundColor(isSelected ? .white : .black)
        }
        .buttonStyle(.plain)
        .buttonClickSound()
    }
}

// MARK: - Отдельный свайпабельный элемент карточки

private struct SwipeableProblemCard: View {
    let scale: CGFloat
    let title: String
    let statusTitle: String
    let statusColor: Color
    let createdDate: String
    let updatedDate: String
    let onSetNotSolved: () -> Void
    let onSetInProgress: () -> Void
    let onSetSolved: () -> Void
    let onDelete: () -> Void
    let onTap: () -> Void

    @State private var offset: CGFloat = 0

    private var maxOffset: CGFloat {
        120 * scale
    }

    private var maxRightOffset: CGFloat {
        200 * scale
    }

    var body: some View {
        ZStack {
            // Левая часть — три круглые кнопки статуса, появляются только при свайпе вправо
            if offset > 0 {
                HStack(spacing: 8 * scale) {
                    Button(action: {
                        onSetNotSolved()
                        offset = 0
                    }) {
                        statusCircle(title: "Not Solved",
                                     color: Color.red)
                    }
                    .buttonStyle(.plain)
                    .buttonClickSound()

                    Button(action: {
                        onSetInProgress()
                        offset = 0
                    }) {
                        statusCircle(title: "In Progress",
                                     color: Color.yellow)
                    }
                    .buttonStyle(.plain)
                    .buttonClickSound()

                    Button(action: {
                        onSetSolved()
                        offset = 0
                    }) {
                        statusCircle(title: "Solved",
                                     color: Color.green)
                    }
                    .buttonStyle(.plain)
                    .buttonClickSound()

                    Spacer()
                }
                .padding(.leading, 5 * scale)
                .transition(.opacity.combined(with: .move(edge: .leading)))
            }

            // Правая часть — кнопка удаления, появляется только при свайпе влево
            if offset < 0 {
                HStack {
                    Spacer()
                    Button(action: {
                        onDelete()
                        offset = 0
                    }) {
                        Circle()
                            .fill(Color(red: 255/255, green: 88/255, blue: 88/255))
                            .frame(width: 46 * scale, height: 46 * scale)
                            .overlay(
                                Image("delete")
                                    .resizable()
                                    .frame(width: 30 * scale, height: 30 * scale)
                                    .foregroundColor(.white)
                            )
                            .shadow(color: Color(red: 255/255, green: 88/255, blue: 88/255).opacity(0.35),
                                    radius: 12 * scale,
                                    x: 0,
                                    y: 8 * scale)
                            .padding(.trailing, 24 * scale)
                    }
                    .buttonStyle(.plain)
                    .buttonClickSound()
                }
                .transition(.opacity.combined(with: .move(edge: .trailing)))
            }

            problemCardContent
                .contentShape(Rectangle())
                .onTapGesture {
                    // Открываем детали только когда карточка в исходном положении,
                    // чтобы не конфликтовать со свайпами.
                    if offset == 0 {
                        onTap()
                    }
                }
                .offset(x: offset)
        }
        .frame(maxWidth: .infinity)
        .gesture(
            DragGesture()
                .onChanged { value in
                    let translation = value.translation.width

                    if translation < 0 {
                        // тянем влево — показываем delete
                        offset = max(translation, -maxOffset)
                    } else {
                        // тянем вправо — показываем статусные кнопки
                        offset = min(translation, maxRightOffset)
                    }
                }
                .onEnded { value in
                    let translation = value.translation.width
                    // если тянули влево
                    if translation < 0 {
                        if translation < -maxOffset / 2 {
                            offset = -maxOffset
                        } else {
                            offset = 0
                        }
                    } else {
                        // тянули вправо
                        if translation > maxRightOffset / 2 {
                            offset = maxRightOffset
                        } else {
                            offset = 0
                        }
                    }
                }
        )
        .animation(.spring(response: 0.25, dampingFraction: 0.9), value: offset)
    }

    private var problemCardContent: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 24 * scale, style: .continuous)
                .fill(Color.white)
                .shadow(color: Color.black.opacity(0.06),
                        radius: 16 * scale,
                        x: 0,
                        y: 8 * scale)

            HStack(alignment: .top, spacing: 16 * scale) {
                // Ледяной кубик слева
                Image("ice")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 52 * scale, height: 52 * scale)

                VStack(alignment: .leading, spacing: 12 * scale) {
                    // Заголовок и статус
                    HStack(alignment: .center) {
                        Text(title)
                            .font(.system(size: 18 * scale, weight: .semibold))
                            .foregroundColor(.black)
                            .lineLimit(2)
                            .fixedSize(horizontal: false, vertical: true)

                        Spacer()

                        HStack(spacing: 6 * scale) {
                            Circle()
                                .fill(statusColor)
                                .frame(width: 10 * scale, height: 10 * scale)

                            Text(statusTitle)
                                .font(.system(size: 14 * scale, weight: .semibold))
                                .foregroundColor(Color(red: 26/255, green: 115/255, blue: 232/255))
                        }
                    }

                    HStack(alignment: .top) {
                        VStack(alignment: .leading, spacing: 4 * scale) {
                            Text("Created:")
                                .font(.system(size: 13 * scale, weight: .medium))
                                .foregroundColor(Color.gray.opacity(0.8))
                            Text(createdDate)
                                .font(.system(size: 13 * scale))
                                .foregroundColor(Color.gray.opacity(0.9))
                        }

                        Spacer()

                        VStack(alignment: .trailing, spacing: 4 * scale) {
                            Text("Updated:")
                                .font(.system(size: 13 * scale, weight: .medium))
                                .foregroundColor(Color.gray.opacity(0.8))
                            Text(updatedDate)
                                .font(.system(size: 13 * scale))
                                .foregroundColor(Color.gray.opacity(0.9))
                        }
                    }
                }
            }
            .padding(20 * scale)
        }
    }

    private func statusCircle(title: String, color: Color) -> some View {
        ZStack {
            Circle()
                .fill(color)
                .frame(width: 46 * scale, height: 46 * scale)
                .shadow(color: color.opacity(0.25),
                        radius: 10 * scale,
                        x: 0,
                        y: 6 * scale)

            Text(title)
                .font(.system(size: 6 * scale, weight: .semibold))
                .foregroundColor(.white)
                .multilineTextAlignment(.center)
                .lineLimit(2)
                .minimumScaleFactor(0.5)
                .padding(2 * scale)
        }
    }
}

// MARK: - Preview

#Preview {
    IcebergArchiveView()
}

