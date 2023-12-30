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

struct GitsaweModel: Hashable, Codable,  Identifiable {
    let id: UUID = UUID();
    var wengel: String?
    var paul: String?
    var meliekt: String?
    var gh: String?
    var kidase: String?
    var psalm: String? 
    var audio: String?
    var misbak: [[KeyValue]]
}



enum PlaybackRate: Float, CaseIterable {
    case half = 0.75
    case normal = 1
    case oneAndQuarter = 1.25
    case oneAndHalf = 1.5
    case two = 2
    var id: Float{ self.rawValue }
}

enum PlaybackState: Int {
    case none
    case buffering
    case playing
    case paused
    case disable
}

enum Behavior: String, CaseIterable, Identifiable, Codable{
    case norepeat = "repeat.circle"
    case repeatAll = "repeat.circle.fill"
    case repeatSingle = "repeat.1.circle.fill"
    var id: String { self.rawValue }
}


struct AudioTrack: Identifiable, Decodable  {
    let id: UUID = UUID()
    public var url: URL?
    public var title: String = ""
    public var subtitle: String = ""
    public var image: String = ""
    
    enum CodingKeys: String, CodingKey{
        case title, image;
    }
}
