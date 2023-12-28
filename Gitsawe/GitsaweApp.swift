//
//  GitsaweApp.swift
//  Gitsawe
//
//  Created by Fekadesilassie on 12/27/23.
//

import SwiftUI

@main
struct GitsaweApp: App {
    
    @StateObject var helper = Helper();
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(helper)
        }
    }
}
