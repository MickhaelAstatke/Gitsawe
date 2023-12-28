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
    @StateObject var handler: AudioHandler = AudioHandler()
    
    var body: some View {
        VStack {
            PagedInfiniteScrollView(content: { index in
                VStack(spacing: 0){
                    
                    Text("\(Formatter.ethWeekDay.string(from: index))")
                        .font(Font.custom("AbyssinicaSIL-Regular", size: 20) )
                        .foregroundStyle(.secondary)
                    
                    HStack(alignment:.center){
                        
                        Button(action: {
                            currentPage = Calendar.current.date(byAdding: .day, value: -1, to: currentPage)!
                        }) {
                            Image(systemName: "chevron.left")
                                .padding()
                                .contentShape(Rectangle())
                        }
                        .buttonStyle(.plain)
                        
                        Spacer()
                        
                        Text("\(Formatter.ethFullDay.string(from: index))")
                            .font(.headline)
                        
                        Spacer()
                        
                        Button(action: {
                            currentPage = Calendar.current.date(byAdding: .day, value: 1, to: currentPage)!
                        }) {
                            Image(systemName: "chevron.right")
                                .padding()
                                .contentShape(Rectangle())
                        }
                        .buttonStyle(.plain)
                    }
                    
                    Divider()
                    
                    Page(date: index)
                        .ignoresSafeArea()
                        .environmentObject(handler)
                        .padding(.top)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(Color(.systemBackground))
                
            }, currentPage: $currentPage)

            
            
            VStack(alignment: .leading){
                
                VStack(alignment: .center){
                    titleAndSubtitle
                    
                    sliderControl
                    
                    timeDisplay
                }
                
                HStack(alignment: .center, spacing: 25){
                    backButton
                    
                    playButton
                    
                    forwardButton
                }
                .frame(maxWidth: .infinity)
            }
            .padding(.horizontal, 25)
            .padding(.bottom, 25)
            .padding(.top)
            .background(Color(.init(red: 20/255, green: 33/255, blue: 56/255, alpha: 1)))
            .foregroundStyle(.white)
            .cornerRadius(15)
            .shadow(radius: 1)
            
        }
        .ignoresSafeArea()
        .edgesIgnoringSafeArea(.all)
        .background(Color(.systemBackground))

        
    }
    
    
    var timeDisplay: some View{
        HStack(alignment: .center, spacing: 50){
            Text("\(Utility.formatSecondsToHMS(self.handler.currentTime))")
                .font(.caption)
            Spacer()
            Text("\(Utility.formatSecondsToHMS(self.handler.currentDuration))")
                .font(.caption)
        }
    }
    
    var titleAndSubtitle: some View{
        HStack(alignment: .center){
            
            Text(handler.currentTrack?.title ?? "ምስባክ")
                .font(Font.custom("AbyssinicaSIL-Regular", size: 17))
            
            Spacer()
            
            Button(action: {
                self.handler.toggleRate()
            }) {
                Text("\(String(self.handler.rate.rawValue))x")
                    .font(.caption.bold())
                    .frame(width: 45, height: 25)
                    .overlay(
                        RoundedRectangle(cornerRadius: 50)
                            .strokeBorder(lineWidth: 2)
                    )
                    .padding(5)
                    .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
            
            Button(action: {
                self.handler.toggleLoop()
            }) {
                Image(systemName: self.handler.loop.rawValue)
                    .resizable()
                    .frame(width: 25, height: 25)
                    .padding(5)
                    .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
            
        }
        .padding(.bottom)
    }
    
    var backButton: some View{
        Button(action: {
            handler.skip(by: -15)
        }) {
            Image(systemName: "gobackward.15")
                .font(.system(size: 25))
                .padding()
                .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .disabled(self.handler.state == .disable)
        
    }
    
    var playButton: some View{
        Button(action: {
            handler.togglePlayPause()
        }) {
            Image(systemName: self.handler.state == .playing ? "pause.fill": "play.fill")
                .font(.system(size: 25))
                .padding(10)
                .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .disabled(self.handler.state == .disable)
    }
    
    var forwardButton: some View{
        Button(action: {
            handler.skip(by: 15)
        }) {
            Image(systemName: "goforward.15")
                .font(.system(size: 25))
                .padding(10)
                .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .disabled(self.handler.state == .disable)
    }
    
    
    var sliderControl: some View{
        Slider(value: self.$handler.currentTime,
               in: 0...self.handler.currentDuration,
               onEditingChanged: sliderEditingChanged ) {
                    Text("seek/progress slider")
            }
           .tint(.white)
           .disabled(self.handler.state == .disable)
    }
    
    
    private func sliderEditingChanged(editingStarted: Bool) {
        if editingStarted {
            handler.timeObserverActive = false;
        }
        else {
            self.handler.skip(to: self.handler.currentTime)
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                handler.timeObserverActive = true;
            }
        }
    }
    
}

#Preview {
    ContentView()
}
