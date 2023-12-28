//
//  Helper.swift
//  Gitsawe
//
//  Created by Fekadesilassie on 12/27/23.
//

import Foundation



class Helper : ObservableObject{
    
    @Published var model: [GitsaweModel];
        
    init() {
        if let path = Bundle.main.path(forResource: "1", ofType: "json") {
            print("path \(path)")
            do {
                let data = try Data(contentsOf: URL(fileURLWithPath: path), options: .mappedIfSafe)
                print(data)
                model = try JSONDecoder().decode([GitsaweModel].self, from: data);
                print(model);
            } catch {
                model = [];//misbak: [KeyValue(t: "1")])
                print(error.localizedDescription);
                print("Unexpected error occured while loading json data")
            }
        }else{
            model = [];//misbak: [KeyValue(t: "1")])
        }
    }
}
