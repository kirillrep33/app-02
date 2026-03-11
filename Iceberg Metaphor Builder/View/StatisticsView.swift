import SwiftUI

/// Экран "Statistics".
/// Показывает либо пустое состояние, либо полноценную статистику — по булевой переменной `hasData`.
struct StatisticsView: View {
    @EnvironmentObject private var router: AppRouter
    @EnvironmentObject private var store: IcebergStore

    @State private var isPresentingCreate: Bool = false

    // MARK: - Derived stats

    private var totalCount: Int {
        store.items.count
    }

    private var solvedItems: [IcebergItem] {
        store.items.filter { $0.status == .solved }
    }

    private var inProgressItems: [IcebergItem] {
        store.items.filter { $0.status == .inProgress }
    }

    private var notSolvedItems: [IcebergItem] {
        store.items.filter { $0.status == .notSolved }
    }

    private var solvedCount: Int { solvedItems.count }
    private var inProgressCount: Int { inProgressItems.count }
    private var notSolvedCount: Int { notSolvedItems.count }

    private var hasData: Bool { totalCount > 0 }

    private var solvedPercent: Double {
        guard totalCount > 0 else { return 0 }
        return (Double(solvedCount) / Double(totalCount)) * 100.0
    }

    private var inProgressPercent: Double {
        guard totalCount > 0 else { return 0 }
        return (Double(inProgressCount) / Double(totalCount)) * 100.0
    }

    private var notSolvedPercent: Double {
        guard totalCount > 0 else { return 0 }
        return (Double(notSolvedCount) / Double(totalCount)) * 100.0
    }

    private var averageLifetimeDays: Int {
        guard !solvedItems.isEmpty else { return 0 }
        let totalSeconds = solvedItems.reduce(0.0) { partial, item in
            partial + item.updatedAt.timeIntervalSince(item.createdAt)
        }
        let days = totalSeconds / 86400.0
        return Int(round(days))
    }

    /// Самый продуктивный месяц по количеству решённых айсбергов.
    private var mostProductiveMonthInfo: (label: String, count: Int)? {
        guard !solvedItems.isEmpty else { return nil }

        var counts: [String: Int] = [:]
        let formatter = DateFormatter()
        formatter.dateFormat = "LLLL yyyy"

        for item in solvedItems {
            let key = formatter.string(from: item.createdAt)
            counts[key, default: 0] += 1
        }

        guard let (label, count) = counts.max(by: { $0.value < $1.value }) else { return nil }
        return (label: label, count: count)
    }

    private func percentString(_ value: Double) -> String {
        String(Int(round(value)))
    }

    private var mostProductiveLabel: String {
        mostProductiveMonthInfo?.label ?? "—"
    }

    private var mostProductiveCountText: String {
        guard let count = mostProductiveMonthInfo?.count else {
            return "0 iceberg"
        }
        return "\(count) iceberg" + (count == 1 ? "" : "s")
    }

    var body: some View {
        GeometryReader { geo in
            let width = geo.size.width
            let scale = width > 0 ? max(width / 393.0, 0.1) : 1.0

            ZStack {
                // Фон как на остальных экранах: мягкий градиент сверху вниз
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
                                .padding(.top, 32 * scale)
                                .padding(.horizontal, 24 * scale)

                            if hasData {
                                contentWithData(scale: scale, availableHeight: geo.size.height)
                                    .padding(.top, 24 * scale)
                            } else {
                                Spacer(minLength: 60 * scale)

                                emptyStateSection(scale: scale, availableHeight: geo.size.height)

                                Spacer(minLength: 80 * scale)
                            }
                        }
                        .frame(maxWidth: .infinity, alignment: .topLeading)
                    }

                    statisticsBottomTabBar(scale: scale) {
                        isPresentingCreate = true
                    }
                        .padding(.bottom, max(geo.safeAreaInsets.bottom, 8 * scale))
                        .background(
                            Color.white
                                .shadow(color: Color.black.opacity(0.05),
                                        radius: 6 * scale,
                                        x: 0,
                                        y: -2 * scale)
                        )
                }
                .ignoresSafeArea(edges: .bottom)
            }
            .fullScreenCover(isPresented: $isPresentingCreate) {
                CreateIcebergView(onFinished: {
                    isPresentingCreate = false
                })
                .environmentObject(router)
                .environmentObject(store)
            }
        }
    }

    // MARK: - Header

    private func headerSection(scale: CGFloat) -> some View {
        HStack {
            Text("Statistics")
                .font(.system(size: 28 * scale, weight: .bold))
                .foregroundColor(.black)

            Spacer()
        }
    }

    // MARK: - Content with data

    private func contentWithData(scale: CGFloat, availableHeight: CGFloat) -> some View {
        VStack(alignment: .leading, spacing: 24 * scale) {
            // Status Distribution
            VStack(alignment: .leading, spacing: 16 * scale) {
                Text("Status Distribution")
                    .font(.system(size: 22 * scale, weight: .semibold))
                    .foregroundColor(.black)

                statusDistributionCard(scale: scale)
            }
            .padding(.horizontal, 24 * scale)

            // Key Metrics
            VStack(alignment: .leading, spacing: 16 * scale) {
                Text("Key Metrics")
                    .font(.system(size: 22 * scale, weight: .semibold))
                    .foregroundColor(.black)

                keyMetricsGrid(scale: scale)
            }
            .padding(.horizontal, 24 * scale)

            // Most Productive Month
            VStack(alignment: .leading, spacing: 16 * scale) {
                Text("Most Productive Month")
                    .font(.system(size: 22 * scale, weight: .semibold))
                    .foregroundColor(.black)

                mostProductiveCard(scale: scale)
            }
            .padding(.horizontal, 24 * scale)

            Spacer(minLength: availableHeight * 0.1)
        }
    }

    private func statusDistributionCard(scale: CGFloat) -> some View {
        let total = Double(solvedCount + inProgressCount + notSolvedCount)
        let notSolvedShare = total > 0 ? Double(notSolvedCount) / total : 0
        let inProgressShare = total > 0 ? Double(inProgressCount) / total : 0
        let solvedShare = total > 0 ? Double(solvedCount) / total : 0

        // Предрасчёт диапазонов срезов (0...1) без мутаций внутри ViewBuilder
        let notSolvedRange = (from: 0.0, to: notSolvedShare)
        let inProgressRange = (from: notSolvedShare, to: notSolvedShare + inProgressShare)
        let solvedRange = (from: notSolvedShare + inProgressShare,
                           to: notSolvedShare + inProgressShare + solvedShare)

        return ZStack {
            // Карточка 350×291, радиус 20, как в макете
            RoundedRectangle(cornerRadius: 20 * scale, style: .continuous)
                .fill(Color.white)
                .shadow(color: Color.black.opacity(0.25),
                        radius: 4 * scale,
                        x: 0,
                        y: 1 * scale)

            VStack(spacing: 24 * scale) {
                // Кольцевая диаграмма по центру в верхней части панели
                HStack {
                    Spacer()
                    ZStack {
                        if total > 0 {
                            // Красный сегмент (Not Solved)
                            if notSolvedShare > 0 {
                                Circle()
                                    .trim(from: notSolvedRange.from, to: notSolvedRange.to)
                                    .stroke(
                                        Color(red: 1.0, green: 77/255, blue: 77/255), // #FF4D4D
                                        style: StrokeStyle(lineWidth: 38 * scale, lineCap: .butt)
                                    )
                                    .rotationEffect(.degrees(-90))
                            }

                            // Жёлтый сегмент (In Progress)
                            if inProgressShare > 0 {
                                Circle()
                                    .trim(from: inProgressRange.from, to: inProgressRange.to)
                                    .stroke(
                                        Color(red: 244/255, green: 237/255, blue: 25/255), // #F4ED19
                                        style: StrokeStyle(lineWidth: 38 * scale, lineCap: .butt)
                                    )
                                    .rotationEffect(.degrees(-90))
                            }

                            // Зелёный сегмент (Solved)
                            if solvedShare > 0 {
                                Circle()
                                    .trim(from: solvedRange.from, to: solvedRange.to)
                                    .stroke(
                                        Color(red: 75/255, green: 225/255, blue: 65/255), // #4BE141
                                        style: StrokeStyle(lineWidth: 38 * scale, lineCap: .butt)
                                    )
                                    .rotationEffect(.degrees(-90))
                            }
                        } else {
                            // Пустое состояние — серое кольцо
                            Circle()
                                .stroke(
                                    Color.gray.opacity(0.2),
                                    style: StrokeStyle(lineWidth: 38 * scale, lineCap: .butt)
                                )
                                .rotationEffect(.degrees(-90))
                        }
                    }
                    .frame(width: 140 * scale, height: 140 * scale)
                    Spacer()
                }
                .padding(.top, 20 * scale)

                // Легенда ниже диаграммы
                HStack(alignment: .top) {
                    VStack(alignment: .leading, spacing: 11 * scale) {
                        legendRow(
                            color: .green,
                            title: "Solved",
                            value: "\(solvedCount) (\(percentString(solvedPercent))%)",
                            scale: scale
                        )
                        legendRow(
                            color: .yellow,
                            title: "In Progress",
                            value: "\(inProgressCount) (\(percentString(inProgressPercent))%)",
                            scale: scale
                        )
                        legendRow(
                            color: .red,
                            title: "Not Solved",
                            value: "\(notSolvedCount) (\(percentString(notSolvedPercent))%)",
                            scale: scale
                        )
                    }
                    .frame(width: 320 * scale, alignment: .leading)
                    Spacer()
                }
                .padding(.bottom, 16 * scale)
            }
            .padding(.horizontal, 15 * scale) // 35 (Figma) − 20 (левая рамка панели)
        }
        .frame(width: 350 * scale, height: 291 * scale)
    }

    private func legendRow(color: Color, title: String, value: String, scale: CGFloat) -> some View {
        HStack {
            Circle()
                .fill(color)
                .frame(width: 12 * scale, height: 12 * scale)

            Text(title)
                .font(.system(size: 14 * scale, weight: .medium))
                .foregroundColor(.black)

            Spacer()

            Text(value)
                .font(.system(size: 14 * scale, weight: .regular))
                .foregroundColor(.black)
        }
    }



    // MARK: - Key Metrics

    private func keyMetricsGrid(scale: CGFloat) -> some View {
        VStack(spacing: 16 * scale) {
            HStack(spacing: 16 * scale) {
                metricCard(
                    title: "Total Created",
                    value: "\(totalCount)",
                    background: Color(red: 236/255, green: 244/255, blue: 255/255),
                    scale: scale
                )

                metricCard(
                    title: "Solved Rate",
                    value: "\(percentString(solvedPercent))%",
                    background: Color(red: 235/255, green: 249/255, blue: 236/255),
                    scale: scale
                )
            }

            HStack(spacing: 16 * scale) {
                metricCard(
                    title: "Avg. Time to Solve",
                    value: solvedCount > 0 ? "\(averageLifetimeDays) days" : "—",
                    background: Color(red: 252/255, green: 242/255, blue: 255/255),
                    scale: scale
                )

                metricCard(
                    title: "In Progress",
                    value: "\(inProgressCount)",
                    background: Color(red: 255/255, green: 244/255, blue: 231/255),
                    scale: scale
                )
            }
        }
    }

    private func metricCard(title: String, value: String, background: Color, scale: CGFloat) -> some View {
        VStack(alignment: .leading, spacing: 12 * scale) {
            Text(title)
                .font(.system(size: 14 * scale, weight: .medium))
                .foregroundColor(Color.gray.opacity(0.8))

            Text(value)
                .font(.system(size: 24 * scale, weight: .semibold))
                .foregroundColor(.black)
        }
        .padding(.horizontal, 18 * scale)
        .padding(.vertical, 18 * scale)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 24 * scale, style: .continuous)
                .fill(background)
        )
    }

    // MARK: - Most productive month

    private func mostProductiveCard(scale: CGFloat) -> some View {
        ZStack {
            RoundedRectangle(cornerRadius: 26 * scale, style: .continuous)
                .fill(
                    LinearGradient(
                        gradient: Gradient(colors: [
                            Color(red: 67/255, green: 145/255, blue: 255/255),
                            Color(red: 26/255, green: 115/255, blue: 232/255)
                        ]),
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )

            VStack(alignment: .leading, spacing: 10 * scale) {
                Text("You created the most icebergs in:")
                    .font(.system(size: 16 * scale, weight: .medium))
                    .foregroundColor(.white)

                Text(mostProductiveLabel)
                    .font(.system(size: 26 * scale, weight: .semibold))
                    .foregroundColor(.white)

                Text(mostProductiveCountText)
                    .font(.system(size: 22 * scale, weight: .medium))
                    .foregroundColor(.white)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, 20 * scale)
            .padding(.vertical, 18 * scale)
        }
        .frame(maxWidth: .infinity)
        .frame(height: 150 * scale)
    }

    // MARK: - Empty state

    private func emptyStateSection(scale: CGFloat, availableHeight: CGFloat) -> some View {
        VStack(spacing: 20 * scale) {
            Image("graph")
                .resizable()
                .scaledToFit()
                .frame(width: 120 * scale, height: 120 * scale)

            VStack(spacing: 6 * scale) {
                Text("No data yet")
                    .font(.system(size: 22 * scale, weight: .semibold))
                    .foregroundColor(Color(red: 52/255, green: 130/255, blue: 255/255))

                Text("Create some icebergs to see statistics")
                    .font(.system(size: 14 * scale))
                    .foregroundColor(.black)
                    .multilineTextAlignment(.center)
            }
        }
        .frame(maxWidth: .infinity)
        .frame(minHeight: availableHeight * 0.35)
    }

    // MARK: - Bottom tab bar

    /// Таб‑бар внизу с активной вкладкой Stats и центральной кнопкой‑плюсом.
    private func statisticsBottomTabBar(scale: CGFloat, onAddTapped: @escaping () -> Void) -> some View {
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
                        Image("1-off")
                            .resizable()
                            .frame(width: 22 * scale, height: 22 * scale)
                        Text("Archive")
                            .font(.system(size: 13 * scale))
                    }
                    .foregroundColor(Color.gray.opacity(0.4))
                    .frame(maxWidth: .infinity)
                }
                .buttonStyle(.plain)
                .buttonClickSound()

                // Центральная круглая кнопка "+"
                Button(action: {
                    onAddTapped()
                }) {
                    ZStack {
                        Circle()
                            .fill(Color(red: 26/255, green: 115/255, blue: 232/255))
                            .frame(width: 44 * scale, height: 44 * scale)

                        Image(systemName: "plus")
                            .foregroundColor(.white)
                            .font(.system(size: 20 * scale, weight: .bold))
                    }
                    .frame(maxWidth: .infinity)
                }
                .buttonStyle(.plain)
                .buttonClickSound()

                // Правая вкладка Stats
                Button {
                    router.selectedTab = .stats
                } label: {
                    VStack(spacing: 4 * scale) {
                        Image("2-on")
                            .resizable()
                            .frame(width: 22 * scale, height: 22 * scale)

                        Text("Stats")
                            .font(.system(size: 13 * scale))
                    }
                    .foregroundColor(Color(red: 26/255, green: 115/255, blue: 232/255))
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

// MARK: - Preview

#Preview {
    StatisticsView()
        .environmentObject(AppRouter())
        .environmentObject(IcebergStore())
}

