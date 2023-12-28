//
//  Helper.swift
//  Gitsawe
//
//  Created by Fekadesilassie on 12/27/23.
//

import Foundation



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
    
    @Published var model: GitsaweModel?;
    @Published var id: String;
        
    init(id: String) {
        if let path = Bundle.main.path(forResource: id, ofType: "json") {
            print("path \(path)")
            do {
                let data = try Data(contentsOf: URL(fileURLWithPath: path), options: .mappedIfSafe)
                model = try JSONDecoder().decode(GitsaweModel.self, from: data);
            } catch {
                print(error.localizedDescription);
                print("Unexpected error occured while loading json data")
            }
        }
        
        self.id = id;
    }
}
