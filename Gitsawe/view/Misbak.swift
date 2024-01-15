//
//  Misbak.swift
//  Gitsawe
//
//  Created by Fekadesilassie on 12/27/23.
//

import SwiftUI

struct Misbak: View {
    
    var misbak: [[KeyValue]];
    
    var body: some View {
        VStack(spacing: 5){
            ForEach(misbak, id: \.self){line in
                WrappingHStack(horizontalSpacing: 0){
                    ForEach(line, id: \.self){l in
                        Letter(letter: l.t, sign: l.s, sign2: l.s2)
                    }
                }
            }
        }
    }
}

#Preview {
    Misbak(misbak: [[KeyValue(t: "ነ", s: "በእ"),KeyValue(t: "w", s: ","),KeyValue(t: "o", s: ""),KeyValue(t: "T", s: "^")]])
}
