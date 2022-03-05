protocol GameDelegate {
    func showWhosTurn()
    func stopShowingWhosTurn()
    func openAllCups(secondPlayerCubesNames: [String], lastBet: Int, myBet: Bool)
}
