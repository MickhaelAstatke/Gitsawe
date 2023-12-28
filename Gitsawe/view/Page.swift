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
    
    init(date: Date){
        let components = date.get(.day, .month, .year, calendar: Calendar.init(identifier: .ethiopicAmeteMihret))

        self.id = "\(components.day! + (components.month! - 1) * 30)";
        helper = Helper(id: id)
        
        print("initializing \(id)")
    }
    
    var body: some View {
        
        VStack(alignment: .leading, spacing: 15){
            if(helper.model != nil){
                
                Text("(\(helper.id)) \(helper.model!.psalm!)")
                    .font(.caption)
                //.font(Font.custom("AbyssinicaSIL-Regular", size: 15) )
                    .foregroundStyle(.secondary)
                
                Misbak(misbak: helper.model!.misbak)
                //.environmentObject(helper)
                
                Text("ዲ.ን.፡ \(helper.model!.paul!)")
                    .font(.caption)
                //.font(Font.custom("AbyssinicaSIL-Regular", size: 15) )
                Text("ንፍቅ ዲ.ን.፡ \(helper.model!.melkit!)")
                    .font(.caption)
                //.font(Font.custom("AbyssinicaSIL-Regular", size: 15) )
                Text("ንፍቅ ካህ.፡\(helper.model!.gh!)")
                    .font(.caption)
                //.font(Font.custom("AbyssinicaSIL-Regular", size: 15) )
                Text("ወንጌል፡ \(helper.model!.wengel!)")
                    .font(.caption)
                //.font(Font.custom("AbyssinicaSIL-Regular", size: 15) )
                Text("ቅዳሴ፡ \(helper.model!.kidase!)")
                    .font(.caption)
                //.font(Font.custom("AbyssinicaSIL-Regular", size: 15) )
            }
        }
    }
}

#Preview {
    Page(date: .now)
}
