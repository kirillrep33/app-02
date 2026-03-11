import Foundation
import SwiftUI


enum MainTab {
    case archive
    case stats
}


final class AppRouter: ObservableObject {
 
    @Published var selectedTab: MainTab = .archive
}

