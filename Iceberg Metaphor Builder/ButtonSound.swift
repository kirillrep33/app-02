import SwiftUI
import AudioToolbox

/// Глобальный проигрыватель звука для нажатия кнопок.
final class ButtonSoundPlayer {
    static let shared = ButtonSoundPlayer()

    private init() {}

    /// Играет короткий системный звук нажатия кнопки.
    func play() {
        // Короткий «клик» iOS. При необходимости можно заменить ID.
        AudioServicesPlaySystemSound(1104)
    }
}

extension View {
    /// Добавляет к любому `View` (в т.ч. `Button`) звук нажатия.
    func buttonClickSound() -> some View {
        self.simultaneousGesture(
            TapGesture().onEnded {
                ButtonSoundPlayer.shared.play()
            }
        )
    }
}

