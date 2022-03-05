protocol BotDelegate {
    var newBet: Int { get set }
    var botCount: Int { get set }
    var playerCount: Int { get set }
    func showCloud(_ firstBet: Bool, _ lie: Bool)
}
