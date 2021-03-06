//
//  ViewController.swift
//  NumberConvertToKorean
//
//  Created by 정해영 on 2020/04/28.
//  Copyright © 2020 sunzero. All rights reserved.
//

import UIKit


enum MainUnit: String, CaseIterable {
    case 조, 억, 만, 일
    
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

class ViewController: UIViewController {

    @IBOutlet weak var numberLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    
    }

       @IBAction func changed(_ sender: UITextField) {

        numberLabel.text = "\(convertByMainUnit(target: sender.text ?? "알수없음"))"
    }
    
    func convertByMainUnit(target: String) -> Int64 {
        func koreanToInt64(target: String) -> Int64 {
            target.map{ KoreanNumber(rawValue: String($0))?.intValue ?? 0 }.reduce(0, +)
        }
        
        func convertBySubUnit(target: String) -> Int64 {
            let removedMainUnit: [MainUnit] = MainUnit.allCases.filter{ $0 != .일 }
            var replacedText = target
            removedMainUnit.forEach {
                replacedText = replacedText.replacingOccurrences(of: $0.rawValue, with: "")
            }
            SubUnit.allCases.forEach {
                replacedText = replacedText.replacingOccurrences(of: $0.rawValue, with: "\($0.rawValue)-")
            }

            let list = replacedText.split(separator: "-").map { value -> Int64 in
                if let subUnit = SubUnit(rawValue: String(value)) { /// value == "천"
                    return subUnit.intValue
                } else if let int = Int64(value) { /// value ==  "120"
                    return int
                } else if let last = value.last, let unit = SubUnit(rawValue: String(last)) { /// value == "7천" or value == "칠천"
                    let numberString = value.filter{ $0 != last }
                    return (Int64(numberString) ?? koreanToInt64(target: numberString)) * unit.intValue
                } else { /// value ==  "3" or value == "삼"
                    return Int64(value) ?? koreanToInt64(target: String(value))
                }
            }
            
            
            return list.reduce(0, +)
        }

        var list: [MainUnit: Int64] = [:]
        let removerdKeys = ",원₩KRW"
        var replacedText = target.uppercased().filter{ !removerdKeys.contains($0) }

        MainUnit.allCases.forEach {
            if $0 != .일 {
                replacedText = replacedText.replacingOccurrences(of: $0.rawValue, with: "\($0.rawValue)-")
            }
        }
        for value in replacedText.split(separator:"-") {
            if let last = value.last, let unit = MainUnit(rawValue: String(last)) {
                if let int = Int64(value.replacingOccurrences(of: String(last), with: "")) {
                    list[unit] = int * unit.intValue
                } else {
                    let convertedValue = convertBySubUnit(target: String(value)) * unit.intValue
                    list[unit] = convertedValue == 0 ? unit.intValue : convertedValue
                }
                
            } else {
                if let int = Int64(value) {
                    list[MainUnit.일] = int
                } else {
                    list[MainUnit.일] = convertBySubUnit(target: String(value))
                }
            }
        }

        return list.values.reduce(0, +)
    }

    
}

