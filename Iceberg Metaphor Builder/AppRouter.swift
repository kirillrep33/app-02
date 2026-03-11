import Foundation
import SwiftUI

/// Основные вкладки приложения.
enum MainTab {
    case archive
    case stats
}

/// Глобальный роутер / состояние навигации.
final class AppRouter: ObservableObject {
    /// Текущая выбранная вкладка в нижней панели.
    @Published var selectedTab: MainTab = .archive
}

