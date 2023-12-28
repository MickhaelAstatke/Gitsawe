//
//  Model.swift
//  Gitsawe
//
//  Created by Fekadesilassie on 12/27/23.
//

import Foundation

struct KeyValue: Hashable, Codable , Identifiable{
    let id: UUID = UUID();
    var t: String;
    var s: String?;
}

struct GitsaweModel:  Codable,  Identifiable {
    let id: UUID = UUID();
    var wengel: String?
    var paul: String?
    var melkit: String?
    var gh: String?
    var kidase: String?
    var psalm: String? 
    var misbak: [[KeyValue]]
}
