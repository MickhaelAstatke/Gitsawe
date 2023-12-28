//
//  ContentView.swift
//  Gitsawe
//
//  Created by Fekadesilassie on 12/27/23.
//

import SwiftUI

struct ContentView: View {
    
    @State var month = 1;
    @State var dayTab = 1;
    
    @State private var currentPage: Date = .now
    
    var body: some View {
        VStack {
            PagedInfiniteScrollView(content: { index in
                VStack{
                    
                    
                    VStack{
                        Text("\(Formatter.ethWeekDay.string(from: index))")
                            .font(Font.custom("AbyssinicaSIL-Regular", size: 25) )
                            .foregroundStyle(.secondary)
                        
                        Text("\(Formatter.ethFullDay.string(from: index))")
                            .font(.title)
                    }
                    
                    
                    
                    Divider()
                    
                    Page(date: index)
                        .padding()
                    
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(Color(.secondarySystemBackground))
                
            }, currentPage: $currentPage)

            HStack {
                Button(action: {
                    //currentPage -= 1
                    currentPage = Calendar.current.date(byAdding: .day, value: -1, to: currentPage)!
                }) {
                    Image(systemName: "chevron.left")
                }
                .padding()
                .cornerRadius(8)

                Button(action: {
                    //currentPage += 1
                    currentPage = Calendar.current.date(byAdding: .day, value: 1, to: currentPage)!
                }) {
                    Image(systemName: "chevron.right")
                }
                .padding()
                .cornerRadius(8)
            }
            .padding(.bottom, 16)
        }
        .edgesIgnoringSafeArea(.all)
        .background(Color(.secondarySystemBackground))

        
    }
}

#Preview {
    ContentView()
}
