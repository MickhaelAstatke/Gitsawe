//
//  Payer.swift
//  Gitsawe
//
//  Created by Fekadesilassie on 2/7/24.
//


import SwiftUI

struct Player: View{
    @EnvironmentObject var ap: AudioHandler;
    @Binding var miniPlayerHeight: CGFloat;
    @Binding var mainPlayerHeight: CGFloat;
    @Binding var currentHeight: PresentationDetent;
    
    var body: some View {
        VStack(alignment: .center){
            GeometryReader { proxy in
                if(proxy.size.height == miniPlayerHeight || currentHeight == .height(miniPlayerHeight)){
                    miniPlayerView
                        .padding(.leading, 5)
                        .padding(.trailing)
                        .padding(.vertical, 5)
                }
                
                largePlayerView
                    .padding(.horizontal, 25)
                    .opacity(currentHeight != .height(mainPlayerHeight) ? 0 : 1)
            }
        }
    }
    
    var miniPlayerView: some View {
        HStack(alignment: .center, spacing: 5){
            playButtonMini
                .padding(.leading, 0)
            
            Text(ap.currentTrack?.title ?? "ምስባክ")
                .font(Font.custom("AbyssinicaSIL-Regular", size: 22))
            
            Spacer()
            
            miniTimeDisplay
            
        }
    }
    
    
    var largePlayerView: some View {
        VStack(alignment: .leading, spacing: 0){
            VStack(alignment: .center){
                titleAndSubtitle
                
                sliderControl
                
                timeDisplay
            }
            
            HStack(alignment: .center, spacing: 25){
                back15Button
                
                playButton
                
                forward15Button
            }
            .frame(maxWidth: .infinity)
        }
        .padding(.vertical)
        .background {
            GeometryReader { proxy in
                Color.clear
                    .task {
                        mainPlayerHeight = proxy.size.height
                    }
            }
        }
    }
      
      var miniTimeDisplay: some View{
          HStack(alignment: .center, spacing: 50){
              Text("\(Utility.formatSecondsToHMS(ap.currentTime)) / \(Utility.formatSecondsToHMS(ap.currentDuration))")
                  .font(.caption)
          }
      }
    
    var timeDisplay: some View{
        HStack(alignment: .center, spacing: 50){
            Text("\(Utility.formatSecondsToHMS(ap.currentTime))")
                .font(.caption)
            Spacer()
            Text("\(Utility.formatSecondsToHMS(ap.currentDuration))")
                .font(.caption)
        }
    }
    
    var titleAndSubtitle: some View{
        HStack(alignment: .center){
            
            Text(ap.currentTrack?.title ?? "ዜማ")
                .font(Font.custom("AbyssinicaSIL-Regular", size: 22))
                .lineLimit(1)
                .minimumScaleFactor(0.9)
            
            Spacer()
            
            Button(action: {
                ap.toggleRate()
            }) {
                Text("\(String(ap.rate.rawValue))x")
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
                ap.toggleLoop()
            }) {
                Image(systemName: ap.loop.rawValue)
                    .resizable()
                    .frame(width: 25, height: 25)
                    .padding(5)
                    .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
            
        }
        .padding(.bottom)
    }
    
    var back15Button: some View{
        Button(action: {
            ap.skip(by: -15)
        }) {
            Image(systemName: "gobackward.15")
                .font(.system(size: 25))
                .padding()
                .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .disabled(ap.state == .disable)
        
    }
    
    var backButton: some View{
        Button(action: {
            ap.back()
        }) {
            Image(systemName: "backward.fill")
                .font(.system(size: 25))
                .padding()
                .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .disabled(ap.state == .disable)
        
    }
    
    var playButtonMini: some View{
        Button(action: {
            ap.togglePlayPause()
        }) {
            Image(systemName: ap.state == .playing ? "pause.fill": "play.fill")
                .font(.system(size: 30))
                .padding(10)
                .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .disabled(ap.state == .disable)
    }
    
    var playButton: some View{
        Button(action: {
            ap.togglePlayPause()
        }) {
            Image(systemName: ap.state == .playing ? "pause.fill": "play.fill")
                .font(.system(size: 50))
                .padding(10)
                .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .disabled(ap.state == .disable)
    }
    
    var forwardButton: some View{
        Button(action: {
            ap.next()
        }) {
            Image(systemName: "forward.fill")
                .font(.system(size: 25))
                .padding(10)
                .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .disabled(ap.state == .disable)
    }
    
    var forward15Button: some View{
        Button(action: {
            ap.skip(by: 15)
        }) {
            Image(systemName: "goforward.15")
                .font(.system(size: 25))
                .padding(10)
                .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .disabled(ap.state == .disable)
    }
    
    
    var sliderControl: some View{
        Slider(value: self.$ap.currentTime,
               in: 0...ap.currentDuration,
               onEditingChanged: sliderEditingChanged ) {
                    Text("seek/progress slider")
            }
           .tint(.white)
           .disabled(ap.state == .disable)
    }
    
    
    private func sliderEditingChanged(editingStarted: Bool) {
        if editingStarted {
            ap.timeObserverActive = false;
        }
        else {
            ap.skip(to: ap.currentTime)
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                ap.timeObserverActive = true;
            }
        }
    }
}



#Preview {
    Player(miniPlayerHeight: .constant(50), mainPlayerHeight: .constant(200), currentHeight: .constant(.large))
}

