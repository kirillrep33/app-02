import SwiftUI
import AudioToolbox


final class ButtonSoundPlayer {
    static let shared = ButtonSoundPlayer()

    private init() {}

   
    func play() {
    
        AudioServicesPlaySystemSound(1104)
    }
}

extension View {

    func buttonClickSound() -> some View {
        self.simultaneousGesture(
            TapGesture().onEnded {
                ButtonSoundPlayer.shared.play()
            }
        )
    }
}

