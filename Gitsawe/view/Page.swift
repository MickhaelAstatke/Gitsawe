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
    
    var track: AudioTrack;
    
    init(date: Date){
        let components = date.get(.day, .month, .year, calendar: Calendar.init(identifier: .ethiopicAmeteMihret))

        self.id = "\(components.day! + (components.month! - 1) * 30)";
        helper = Helper(id: id)
        
        
        //TODO: Fetch this from the helper.model
        track = AudioTrack();
        track.image = "eotc-celebration"; // Image name from asset
        track.title = "ምስባክ"
        track.subtitle = "ዘ\(Formatter.ethFullDay.string(from: date))"
        track.url = Bundle.main.url(forResource: helper.model?.audio, withExtension: "m4a"); //Path of the audio file
        
        print(track)
        NotificationCenter.default.post(name: Notification.Name("com.gitsawe.LOAD"), object: [track]  )
    }
    
    var body: some View {
        
        VStack(alignment: .leading, spacing: 0){
            if(helper.model != nil){
                
                Text("(\(helper.id)) \(helper.model!.psalm!)")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .padding(.bottom)
                    .padding(.horizontal)
                
                Misbak(misbak: helper.model!.misbak)
                    .padding(.bottom)
                    .padding(.horizontal)
                
                Row(title: "ዲ.ን.", value: helper.model!.paul!)
                    .background(Color(.systemGroupedBackground).opacity(0.7))
                Row(title: "ንፍቅ ዲ.ን.", value: helper.model!.melkit!)
                Row(title: "ንፍቅ ካህን", value: helper.model!.gh!)
                    .background(Color(.systemGroupedBackground).opacity(0.7))
                Row(title: "ወንጌል", value: helper.model!.wengel!)
                Row(title: "ቅዳሴ", value: helper.model!.kidase!)
                    .background(Color(.systemGroupedBackground).opacity(0.7))
                
                Spacer()
                
                
            }else{
                Text("Missing or Incorrect \(helper.id).json")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                
                Spacer()
            }
        }
        .padding(.vertical)
    }
    
}

#Preview {
    Page(date: .now)
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
