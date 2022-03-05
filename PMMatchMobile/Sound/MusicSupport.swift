import AVFoundation

var player: AVAudioPlayer?

func sound(_ sound: String) {
    guard let url = Bundle.main.url(forResource: sound, withExtension: "mp3") else { return }

    do {
        try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default)
        try AVAudioSession.sharedInstance().setActive(true)

        player = try AVAudioPlayer(contentsOf: url, fileTypeHint: AVFileType.mp3.rawValue)
        
        guard let player = player else { return }
        
        player.volume = 0.8
        player.play()

    } catch let error {
        print(error.localizedDescription)
    }
}
