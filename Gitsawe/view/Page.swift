//
//  Page.swift
//  Gitsawe
//
//  Created by Fekadesilassie on 12/28/23.
//

import SwiftUI

struct Page: View {
    @StateObject var helper = Helper(id: "1");
    
    var body: some View {
        VStack(spacing: 50){
            Text("\(helper.id)")
                .font(Font.custom("AbyssinicaSIL-Regular", size: 30) )
                .foregroundStyle(.secondary)
            
            VStack(alignment: .leading, spacing: 15){
                if(helper.model != nil){
                    
                    Text("ምስባክ፡ \(helper.model!.psalm!)")
                        .font(Font.custom("AbyssinicaSIL-Regular", size: 15) )
                        .foregroundStyle(.secondary)
                    
                    Misbak(misbak: helper.model!.misbak)
                    //.environmentObject(helper)
                    
                    Text("ዲ.ን.፡ \(helper.model!.paul!)")
                        .font(Font.custom("AbyssinicaSIL-Regular", size: 15) )
                    Text("ንፍቅ ዲ.ን.፡ \(helper.model!.melkit!)")
                        .font(Font.custom("AbyssinicaSIL-Regular", size: 15) )
                    Text("ንፍቅ ካህ.፡\(helper.model!.gh!)")
                        .font(Font.custom("AbyssinicaSIL-Regular", size: 15) )
                    Text("ወንጌል፡ \(helper.model!.wengel!)")
                        .font(Font.custom("AbyssinicaSIL-Regular", size: 15) )
                    Text("ቅዳሴ፡ \(helper.model!.kidase!)")
                        .font(Font.custom("AbyssinicaSIL-Regular", size: 15) )
                }
            }
        }
    }
}

#Preview {
    Page()
}
