//
//  Letter.swift
//  Gitsawe
//
//  Created by Fekadesilassie on 12/27/23.
//

import SwiftUI

struct Letter: View {
    var letter: String;
    var sign: String?;
    var sign2: String?;
    
    var body: some View {
        VStack(spacing: 0){
            Text(sign2 ?? " ")
                .font(.system(size: 8))
                .frame(height: 13)
            
            Text(sign ?? " ")
                .font(.system(size: 8))
                .frame(height: 9)
            
            Text(letter)
                .font(Font.custom("AbyssinicaSIL-Regular", size: 25) )
                .minimumScaleFactor(0.8)
        }
    }
}

#Preview {
    Letter(letter: "H", sign: "^")
}
