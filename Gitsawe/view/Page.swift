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

        let month = Formatter.ethMonthEng.string(from: date).lowercased();
        let dayOfWeek = Formatter.ethWeekDay.string(from: date);
        print("\(date) -- \(month) -- \(dayOfWeek)")
        
        
        if(dayOfWeek == "እሑድ"){
            self.id = "mezmur_ብርሃን"; // using መዝሙር_xyz for e.g. መዝሙር_ብርሃን. TODO: check which week and add logic for the mezmur
        }else{
            self.id = "\(month)_\(components.day!)"; // using month_dd for e.g. meskerem_2
        }
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
        
        print(playlist.count)
        audioPlayer.loadPlaylist(tracks: playlist)
    }
    
    var body: some View {
        
        VStack(alignment: .leading, spacing: 0){
            
            ForEach(helper.model, id: \.self){model in
                
                HStack{
                    Text(model.title)
                        .font(Font.custom("AbyssinicaSIL-Regular", size: 23) )
                        .foregroundStyle(.secondary)
                    
                    Spacer()
                    
                    Text(model.psalm!)
                        .font(.subheadline)
                }
                .padding(.horizontal)
                .padding(.bottom)

                
                Misbak(misbak: model.misbak)
                    .padding(.horizontal)
                
                if(model.paul != nil){
                    Row(title: "ዲ.ን.", value: model.paul!)
                        .background(Color(.secondarySystemBackground).opacity(0.7))
                        .font(.subheadline)
                }
                
                if(model.meliekt != nil){
                    Row(title: "ንፍቅ ዲ.ን.", value: model.meliekt!)
                        .font(.subheadline)
                }
                    
                if(model.gh != nil){
                    Row(title: "ንፍቅ ካህን", value: model.gh!)
                        .background(Color(.secondarySystemBackground).opacity(0.7))
                        .font(.subheadline)
                }
                        
                Row(title: "ወንጌል", value: model.wengel!)
                    .font(.subheadline)
                    .background(model.gh == nil ? Color(.secondarySystemBackground).opacity(0.7) : Color(.systemBackground))
                        
                if(model.kidase != nil){
                    Row(title: "ቅዳሴ", value: model.kidase!)
                        .background(Color(.secondarySystemBackground).opacity(0.7))
                        .font(.subheadline)
                }
                
                Spacer(minLength: 50)
            }
            
            
            HStack{
                Spacer()
                Text("from \(helper.id).json")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .padding(.horizontal)
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
                //.font(.subheadline)
                .foregroundStyle(.secondary)
            
            Text(value)
                //.font(.subheadline)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
    }
    
}
