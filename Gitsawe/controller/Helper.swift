//
//  Helper.swift
//  Gitsawe
//
//  Created by Fekadesilassie on 12/27/23.
//

import Foundation

/*
 usage enum Direction: CaseIterable {
 case east, south, west, north
}

print(Direction.east.next()) // south
print(Direction.north.next()) // east
 
 */
extension CaseIterable where Self: Equatable {
    func next() -> Self {
        let all = Self.allCases
        let idx = all.firstIndex(of: self)!
        let next = all.index(after: idx)
        return all[next == all.endIndex ? all.startIndex : next]
    }
}

extension Formatter {
    
    static let greFullDay: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM dd, yyyy"
        return formatter
    }()
    
    
    static let ethFullDay: DateFormatter = {
        let formatter = DateFormatter()
        formatter.calendar = Calendar.init(identifier: Calendar.Identifier.ethiopicAmeteMihret)
        formatter.locale = Locale(identifier: "amh")
        formatter.dateFormat = "MMMM dd, yyyy"
        return formatter
    }()
    
    
    static let ethMonth: DateFormatter = {
        let formatter = DateFormatter()
        formatter.calendar = Calendar.init(identifier: Calendar.Identifier.ethiopicAmeteMihret)
        formatter.locale = Locale(identifier: "amh")
        formatter.dateFormat = "MMMM"
        return formatter
    }()
    
    static let ethMonthEng: DateFormatter = {
        let formatter = DateFormatter()
        formatter.calendar = Calendar.init(identifier: Calendar.Identifier.ethiopicAmeteMihret)
        formatter.dateFormat = "MMMM"
        return formatter
    }()
    
    
    static let ethWeekDay: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "amh")
        formatter.dateFormat = "cccc"
        return formatter
    }()
}

extension Date {
    func get(_ components: Calendar.Component..., calendar: Calendar = Calendar.current) -> DateComponents {
        return calendar.dateComponents(Set(components), from: self)
    }

    func get(_ component: Calendar.Component, calendar: Calendar = Calendar.current) -> Int {
        return calendar.component(component, from: self)
    }
}

class Helper : ObservableObject{
    
    @Published var model: [GitsaweModel];
    @Published var id: String;
        
    init(id: String) {
        print("loading \(id)")
        self.model = [];
        if let path = Bundle.main.path(forResource: id, ofType: "json") {
            print("path \(path)")
            do {
                let data = try Data(contentsOf: URL(fileURLWithPath: path), options: .mappedIfSafe)
                model = try JSONDecoder().decode([GitsaweModel].self, from: data);
            } catch {
                print(error.localizedDescription);
                print("Unexpected error occured while loading json data")
            }
        }
        
        self.id = id;
    }
}


class Utility: NSObject {
    
    private static var timeHMSFormatter: DateComponentsFormatter = {
        let formatter = DateComponentsFormatter()
        formatter.unitsStyle = .positional
        formatter.allowedUnits = [.minute, .second]
        formatter.zeroFormattingBehavior = [.pad]
        return formatter
    }()
    
    static func formatSecondsToHMS(_ seconds: Double) -> String {
        guard !seconds.isNaN,
            let text = timeHMSFormatter.string(from: seconds) else {
                return "00:00"
        }
         
        return text
    }
    
}
