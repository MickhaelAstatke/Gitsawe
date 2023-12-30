//
//  Page.swift
//  Gitsawe
//
//  Created by Fekadesilassie on 12/28/23.
//

import SwiftUI

struct Page: View {
    var id: String;
    var helper: Helper;
    
    init(date: Date, audioPlayer: AudioHandler){
        let components = date.get(.day, .month, .year, calendar: Calendar.init(identifier: .ethiopicAmeteMihret))

        self.id = "\(components.day! + (components.month! - 1) * 30)";
        helper = Helper(id: id)
        
        
        var playlist:[AudioTrack] = [];
        helper.model.forEach { model in
            var track = AudioTrack();
            track.image = "eotc-celebration"; // Image name from asset
            track.title = "ምስባክ"
            track.subtitle = "ዘ\(Formatter.ethFullDay.string(from: date))"
            track.url = Bundle.main.url(forResource: model.audio, withExtension: "m4a");
            playlist.append(track);
        }
        
        print(playlist)
        audioPlayer.loadPlaylist(tracks: playlist)
    }
    
    var body: some View {
        
        VStack(alignment: .leading, spacing: 0){
            
            ForEach(helper.model, id: \.self){model in
                Text(model.psalm!)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .padding(.bottom)
                    .padding(.horizontal)
                
                Misbak(misbak: model.misbak)
                    .padding(.bottom)
                    .padding(.horizontal)
                
                Row(title: "ዲ.ን.", value: model.paul!)
                    .background(Color(.systemGroupedBackground).opacity(0.7))
                Row(title: "ንፍቅ ዲ.ን.", value: model.meliekt!)
                Row(title: "ንፍቅ ካህን", value: model.gh!)
                    .background(Color(.systemGroupedBackground).opacity(0.7))
                Row(title: "ወንጌል", value: model.wengel!)
                Row(title: "ቅዳሴ", value: model.kidase!)
                    .background(Color(.systemGroupedBackground).opacity(0.7))
                
                HStack{
                    Spacer()
                    Text("from \(helper.id).json")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .padding(.horizontal)
                }
            }
            
            if(helper.model.count == 0){
                Text("Missing or Incorrect \(helper.id).json")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                
            }
            
            Spacer()
        }
        .padding(.vertical)
    }
    
}

#Preview {
    Page(date: .now, audioPlayer: AudioHandler())
}


struct Row: View {
    
    var title: String;
    var value: String;
    
    var body: some View {
        HStack{
            Text(title)
                .font(.subheadline)
                .foregroundStyle(.secondary)
            
            Text(value)
                .font(.subheadline)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
    }
    
}
