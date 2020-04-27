import UIKit

enum MainUnit: String, CaseIterable {
    case 만,억,조
    
    var intValue: Int64 {
        switch self {
        case .만: return 10_000
        case .억: return 100_000_000
        case .조: return 1_000_000_000_000
        }
    }
}

enum SubUnit: String, CaseIterable {
    case 십,백,천
    
    var intValue: Int64 {
        switch self {
        case .십: return 10
        case .백: return 100
        case .천: return 1000
        }
    }
}

enum KoreanNumber: String, CaseIterable {
    case 일,이,삼,사,오,육,칠,팔,구
    
    var intValue: Int64 {
        switch self {
        case .일: return 1
        case .이: return 2
        case .삼: return 3
        case .사: return 4
        case .오: return 5
        case .육: return 6
        case .칠: return 7
        case .팔: return 8
        case .구: return 9
        }
    }
}

func covertBySubUnit(target: String) -> Int64 {
    var sum: Int64 = 0
    var prevSubUnit: SubUnit? = nil
    target.reversed().forEach {
        if let findedSubUnit = SubUnit(rawValue: String($0)) {
            if let subUnit = prevSubUnit {
                sum  += subUnit.intValue
                prevSubUnit = nil
            }
            prevSubUnit = findedSubUnit
            
        } else if let koreanNumber = KoreanNumber(rawValue: String($0)) {
            if let subUnit = prevSubUnit {
                sum += koreanNumber.intValue * subUnit.intValue
                prevSubUnit = nil
            } else {
                sum += koreanNumber.intValue
            }
        }
    }
    if let subUnit = prevSubUnit {
        sum  += subUnit.intValue
    }
    return sum
}


func convertByMainUnit(target: String) -> Int64 {
    var sum: Int64 = 0
    var prevMainUnit: MainUnit? = nil
    var splitFirst: String = target
    
    MainUnit.allCases.forEach { mainUnit in
        if splitFirst.contains(mainUnit.rawValue) {
            prevMainUnit = mainUnit
            let first = splitFirst.split(separator: Character(mainUnit.rawValue)).first
            let last = splitFirst.split(separator: Character(mainUnit.rawValue)).last

            if first == nil, last == nil {
                sum += mainUnit.intValue
            } else if first == last {
                if let first = first {
                    splitFirst = String(first)
                }
            } else {
                if let first = first {
                    splitFirst = String(first)
                }
                if let last = last {
                    sum += convertByMainUnit(target: String(last))  * (mainUnit.intValue / MainUnit.만.intValue)
                }
            }
        }
    }
    
    if let prevMainUnit = prevMainUnit {
        sum += covertBySubUnit(target: String(splitFirst)) * prevMainUnit.intValue
    } else {
        sum += covertBySubUnit(target: String(splitFirst))
    }
    
    return sum
}


convertByMainUnit(target: "사십육억칠천칠백구십이만오천삼백원")
