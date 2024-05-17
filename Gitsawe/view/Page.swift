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
                
                HStack(alignment: .center){
                    
                    RoundedRectangle(cornerRadius: 10.0)
                        .fill(.green)
                        .frame(width: 5)
                    
                    Text(model.title)
                        .font(Font.custom("AbyssinicaSIL-Regular", size: 23) )
                    
                    Spacer()
                    
                    Text(model.psalm!)
                        .font(.subheadline)
//                        .font(Font.custom("AbyssinicaSIL-Regular", size: 23) )
                }
                .foregroundColor(.secondary)
                .padding(.horizontal)
//                .padding(.bottom)
                .frame(maxWidth: .infinity, alignment: .leading)

                
                Misbak(misbak: model.misbak)
                    .padding(.horizontal)
                    .padding(.bottom)
                
                
                LazyVGrid(columns:  [
                    GridItem(.flexible(), spacing: 10, alignment: .trailing),
                    GridItem(.flexible(), spacing: 10, alignment: .leading),
                ], spacing: 10) {
                    
                    if(model.paul != nil){
                        Row(title: "ዲ.ን.", value: model.paul!)
                        // .background(Color(.secondarySystemBackground).opacity(0.7))
                            .font(Font.custom("AbyssinicaSIL-Regular", size: 18) )
                            
                    }
                    
                    if(model.meliekt != nil){
                        Row(title: "ንፍቅ \nዲ.ን.", value: model.meliekt!)
                            .font(Font.custom("AbyssinicaSIL-Regular", size: 18) )
                    }
                    
                    if(model.gh != nil){
                        Row(title: "ንፍቅ \nካህን", value: model.gh!)
                        // .background(Color(.secondarySystemBackground).opacity(0.7))
                            .font(Font.custom("AbyssinicaSIL-Regular", size: 18) )
                    }
                    
                    Row(title: "ወንጌል", value: model.wengel!)
                        .font(Font.custom("AbyssinicaSIL-Regular", size: 18) )
                    //.background(model.gh == nil ? Color(.secondarySystemBackground).opacity(0.7) : Color(.systemBackground))
                    
                    
                    if(model.kidase != nil){
                        Row(title: "ቅዳሴ", value: model.kidase!)
                        // .background(Color(.secondarySystemBackground).opacity(0.7))
                            .font(Font.custom("AbyssinicaSIL-Regular", size: 18) )
                    }
                }
                .padding(.horizontal)
                
                Spacer(minLength: 60)
            }
            
            
            
            if(helper.model.count == 0){
                Text("Missing or Incorrect \(helper.id).json")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                
            }else{
                HStack{
                    Spacer()
                    Text("from \(helper.id).json")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .padding(.horizontal)
                }
            }
            
            Spacer()
                .frame(minHeight: 75)
        }
        .padding(.vertical)
    }
    
}

#Preview {
    Page(date: .now, audioPlayer: AudioHandler())
}


struct Row2: View {
    
    var title: String;
    var value: String;
    
    var body: some View {
        HStack{
//            RoundedRectangle(cornerRadius: 10.0)
//                .fill(.green)
//                .frame(width: 5)

            Text(title)
                //.font(.subheadline)
                .foregroundStyle(.secondary)
            
            Text(value)
                .minimumScaleFactor(0.5)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
//        .padding()
    }
    
}

struct Row: View {
    
    var title: String;
    var value: String;
    
    var body: some View {
        HStack(spacing: 5){
            Text(title)
                .foregroundStyle(.secondary)
                .font(.caption)
                .minimumScaleFactor(0.6)
            
            Text(value)
                .minimumScaleFactor(0.4)
                .multilineTextAlignment(.center)
                .foregroundStyle(.primary.opacity(0.8))
        }
        .frame(maxWidth: .infinity, alignment: .center)
        .padding(.vertical,7)
        .padding(.horizontal,7)
        .background(Material.ultraThin)
        .cornerRadius(10.0)
        .clipped()
    }
    
}
