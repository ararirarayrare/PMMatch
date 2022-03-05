import Foundation
import UIKit

struct Bot {
    
    static let shared = Bot()
    
     func setFirstBet(_ botCount: Int,_ playerCount: Int) -> Int {
         UserDefaults.standard.set(botCount + playerCount, forKey: "realCount")
        
        var x = 0
        var y = 0
        var boolRandom = Bool.random()
        
        switch UserDefaults.standard.integer(forKey: "difficulty") {
        case 0:
            x = 10
            y = 6
        case 1:
            x = 6
            y = 4
        case 2:
            x = 2
            y = 2
            boolRandom = false
        default:
            break
        }
        
        
        let botCount = Float(botCount)
        
        let approximatePlayerCount = Int.random(in: playerCount - x...playerCount + x)
        let difference = approximatePlayerCount / Int.random(in: (y / 2)...y)
        
        var step = 0
        
        if boolRandom {
            step = Int.random(in: (difference / 2)...(difference))
        } else {
            step = Int.random(in: (-difference)...(-difference / 2))
        }
    
        var firstBet = Int(botCount) + approximatePlayerCount + step
        if firstBet > 60 {
            let difference = firstBet - 60
            firstBet -= difference
        }
        return firstBet
    }
    
    func riseBet(_ setBet: Int,_ oldBet: Int) -> Int {
        
        var multiplier: Double = 0

        var newBet = 0
        
        switch UserDefaults.standard.integer(forKey: "difficulty") {
        case 0:
            multiplier = 1.6
        case 1:
            multiplier = 1.2
        case 2:
            guard (setBet - UserDefaults.standard.integer(forKey: "realCount")) < 8 else { return UserDefaults.standard.integer(forKey: "realCount") }
            return setBet + 4
        default:
            break
        }
        
        let difference = Int(Double(setBet - oldBet) * multiplier)
        let step = Int.random(in: 1...difference)
        
        newBet = setBet + step
        if newBet > 60 {
            let difference = newBet - 60
            newBet -= difference
        }
        return newBet
    }
    
    func betRised(_ newBet: Int,_ oldBet: Int) -> Bool {
        var step = 0
        switch newBet {
        case 60:
            return false
        case 53...59:
            step = 8
        case 47...52:
            step = 5
        case 42...46:
            step = 4
        case 37...41:
            step = 3
        case 25...36:
            step = 2
        case 0...28:
            step = 1
        default:
            break
        }
        
        switch UserDefaults.standard.integer(forKey: "difficulty") {
        case 0...1:
            let random = Int.random(in: 1...step)
            if random == 1 {
                return true
            } else {
                return false
            }
        case 2:
            if newBet > UserDefaults.standard.integer(forKey: "realCount") {
                return false
            } else {
                return true
            }
        default:
            return false
        }
    }
}
