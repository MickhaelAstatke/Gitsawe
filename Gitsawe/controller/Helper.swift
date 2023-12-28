//
//  Helper.swift
//  Gitsawe
//
//  Created by Fekadesilassie on 12/27/23.
//

import Foundation



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
