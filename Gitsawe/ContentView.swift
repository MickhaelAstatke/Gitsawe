//
//  ContentView.swift
//  Gitsawe
//
//  Created by Fekadesilassie on 12/27/23.
//

import SwiftUI

struct ContentView: View {
    @EnvironmentObject private var helper: Helper
    
    
    var body: some View {
        VStack {
            Misbak()
                .environmentObject(helper)
        }
        .padding()
    }
}

#Preview {
    ContentView()
}
