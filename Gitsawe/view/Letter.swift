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
    
    var body: some View {
        VStack(spacing: 0){
            Text(sign ?? " ")
                .font(.system(size: 7))
                .frame(height: 7)
            
            Text(letter)
                //.font(.system(size: 20))
                .font(Font.custom("AbyssinicaSIL-Regular", size: 21) )
        }
    }
}

#Preview {
    Letter(letter: "H", sign: "^")
}
