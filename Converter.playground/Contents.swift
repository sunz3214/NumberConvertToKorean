import UIKit

enum MainUnit: String, CaseIterable {
    case 조,억,만,일

    var intValue: Int64 {
        switch self {
        case .일: return 1
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
//
//
//func convertByMainUnit(target: String) -> Int64 {
//    guard !target.isEmpty else { return 0 }
//    var sum: Int64 = 0
//    var nextTarget = target
//    for mainUnit in MainUnit.allCases {
//        let split = nextTarget.split(separator: Character(mainUnit.rawValue))
//        if split.count == 1, let first = split.first {
//            if nextTarget.contains(mainUnit.rawValue) {
//                sum += covertBySubUnit(target: String(first)) * mainUnit.intValue
//            } else {
//                sum += covertBySubUnit(target: String(first))
//            }
//            break
//        } else {
//            if let first = nextTarget.split(separator: Character(mainUnit.rawValue)).first {
//                sum += covertBySubUnit(target: String(first)) * mainUnit.intValue
//            }
//            if let last = nextTarget.split(separator: Character(mainUnit.rawValue)).last {
//                if MainUnit.allCases.last == mainUnit {
//                    sum += covertBySubUnit(target: String(last))
//                } else {
//                    nextTarget = String(last)
//                }
//            }
//        }
//    }
//
//    return sum
//}
//
////convertByMainUnit(target: "이천십")

let a = "이천십"
var reA = a
MainUnit.allCases.forEach {
    reA = reA.replacingOccurrences(of: $0.rawValue, with: "\($0.rawValue),")
}

let split = reA.split(separator:",").compactMap{ String($0) }

var list: [MainUnit: Int64] = [:]

for value in split {
  for unit in MainUnit.allCases {
        if value.contains(unit.rawValue) {
            list[unit] = covertBySubUnit(target: value)
        } else {
            list[MainUnit.일] = covertBySubUnit(target: value)
        }
    }
}

list.keys.forEach {
    if list[$0] == 0, $0 != .일 {
        list[$0] = $0.intValue
    }
}
let sum = list.values.reduce(0, +)

print(sum)
