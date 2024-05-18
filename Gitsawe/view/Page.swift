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
                Accordion(model: model)
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


struct Accordion: View {
    
    var model: GitsaweModel;
    @State var isExpanded: Bool = true;
    
    var body: some View {
        
        DisclosureGroup(isExpanded: $isExpanded) {
            
            Misbak(misbak: model.misbak)
                .padding(.bottom)
            
            VStack(spacing: 10){
                //HStack(spacing: 10){
                    
                    if(model.paul != nil){
                        Row(title: "ሠራዒ ዲ.ን.", value: model.paul!)
                    }
                    
                    if(model.meliekt != nil){
                        Row(title: "ንፍቅ ዲ.ን.", value: model.meliekt!)
                    }
                //}
                
                //HStack(spacing: 10){
                    if(model.gh != nil){
                        Row(title: "ንፍቅ ካህን", value: model.gh!)
                    }
                    
                    Row(title: "ወንጌል", value: model.wengel!, nobreak: model.paul == nil)
                //}
                
                //HStack(spacing: 10){
                    if(model.kidase != nil){
                        Row(title: "ቅዳሴ", value: model.kidase!)
                            .font(Font.custom("AbyssinicaSIL-Regular", size: 18) )
                    }
                //}
            }
            
            Spacer(minLength: 60)
        }
    label: {
        HStack{
            RoundedRectangle(cornerRadius: 10.0)
                .fill(.green)
                .frame(width: 5)
            
            VStack(alignment: .leading){
                Text(model.title)
                    .font(Font.custom("AbyssinicaSIL-Regular", size: 23) )
                
                Text(model.psalm!)
                    .font(.caption)
            }
            .foregroundColor(.primary.opacity(0.8))
        }
        .underline(false)
    }
    .disclosureGroupStyle(AccordionStyle())
    .padding(.horizontal)
    .padding(.vertical)
    }
}


struct AccordionStyle: DisclosureGroupStyle {
    func makeBody(configuration: Configuration) -> some View {
        VStack(alignment: .leading) {
            
            Button(action: {
                withAnimation{
                    configuration.isExpanded.toggle()
                }
            }, label: {
                HStack {
                    configuration.label
                    Spacer()
                    Image(systemName: configuration.isExpanded ? "chevron.down" :"chevron.right")
                }
                .frame(maxWidth: .infinity)
                .contentShape(Rectangle())
            })
            .buttonStyle(.plain)

            if configuration.isExpanded {
                configuration.content
                    .padding(.leading, 5)
            }
        }
    }
}

struct Row: View {
    
    var title: String;
    var value: String;
    var nobreak: Bool?;
    
    init(title: String, value: String, nobreak: Bool? = nil) {
        self.title = title
        self.nobreak = nobreak
        self.value = value
        
        
        if(self.nobreak == true || true){
            self.title = self.title.replacingOccurrences(of: "\n", with: "")
            self.value = self.value.replacingOccurrences(of: "\n", with: "")
        }
    }
    
    var body: some View {
        HStack(spacing: 15){
            
            LazyVGrid(columns: [GridItem(.fixed(90), alignment: .leading), GridItem(.flexible(), alignment: .leading)], content: {
                
                Text(title)
                    .foregroundStyle(.secondary)
                    .font(Font.custom("AbyssinicaSIL-Regular", size: 18) )
                
                
                Text(value)
                    .minimumScaleFactor(0.4)
                    .multilineTextAlignment(.center)
                    .foregroundStyle(.primary.opacity(0.8))
                    .font(Font.custom("AbyssinicaSIL-Regular", size: 18) )
            })
            
            //Spacer()
            
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.vertical,7)
        .padding(.horizontal, 7)
        .background(Material.ultraThin)
        .cornerRadius(10.0)
        .clipped()
    }
    
}
