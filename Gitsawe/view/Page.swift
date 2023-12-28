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
        track.url = Bundle.main.url(forResource: "ሰላም", withExtension: "m4a"); //Path of the audio file
        
        print(track)
        NotificationCenter.default.post(name: Notification.Name("com.gitsawe.LOAD"), object: [track]  )
    }
    
    var body: some View {
        
        VStack(alignment: .leading, spacing: 25){
            if(helper.model != nil){
                
                Text("(\(helper.id)) \(helper.model!.psalm!)")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                
                Misbak(misbak: helper.model!.misbak)
                
                Text("ዲ.ን.፡ \(helper.model!.paul!)")
                    .font(.subheadline)
                Text("ንፍቅ ዲ.ን.፡ \(helper.model!.melkit!)")
                    .font(.subheadline)
                Text("ንፍቅ ካህ.፡\(helper.model!.gh!)")
                    .font(.subheadline)
                Text("ወንጌል፡ \(helper.model!.wengel!)")
                    .font(.subheadline)
                Text("ቅዳሴ፡ \(helper.model!.kidase!)")
                    .font(.subheadline)
                
                Spacer()
                
                
            }else{
                Text("Missing or Incorrect \(helper.id).json")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                
                Spacer()
            }
        }
        .padding()
    }
    
}

#Preview {
    Page(date: .now)
}
