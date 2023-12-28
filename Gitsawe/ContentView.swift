//
//  ContentView.swift
//  Gitsawe
//
//  Created by Fekadesilassie on 12/27/23.
//

import SwiftUI

struct ContentView: View {
    
    @State var dayTab = 1;
    
    var body: some View {
        VStack {
            
            TabView(selection: $dayTab.animation(.easeIn)) {
                ForEach(1...30, id: \.self) { id  in
                    Page(id: "\(id)")
                        .tag(id)
                }
            }
            .tableStyle(.inset)
            .tabViewStyle(.page(indexDisplayMode: .never))
            
        }
        .padding()
    }
}

#Preview {
    ContentView()
}
