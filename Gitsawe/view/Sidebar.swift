//
//  Sidebar.swift
//  Gitsawe
//
//  Created by Fekadesilassie on 5/26/24.
//

import SwiftUI

import SwiftUI

struct Sidebar: View {
    @Binding var isSideBarOpened: Bool
    let sideBarWidth: CGFloat = min(UIScreen.main.bounds.size.width * 0.65, 300)
    
    var body: some View {
        ZStack {
            GeometryReader { _ in
                EmptyView()
            }
            .background(Color.black.opacity(0.7))
            .opacity(isSideBarOpened ? 1 : 0)
            .animation(.easeInOut, value: isSideBarOpened)
            .onTapGesture {
                isSideBarOpened = false
            }

            content
        }
        .foregroundColor(.primary)
        .edgesIgnoringSafeArea(.all)
    }

    private var content: some View {
        HStack(alignment: .top) {
            ZStack(alignment: .top) {
                Color(.secondarySystemBackground)

                MenuChevron

                VStack(alignment: .leading, spacing: 20) {
                    userProfile
                    
                    Divider()
                        .background(Color.green.opacity(0.5))
                    
                    VStack(alignment: .leading, spacing: 5) {
                        navigationLink(icon: "book.closed", text: "መቅድም", content: ContentView())
                        
                        menuLink(icon: "doc.text", text: "ምስባክ", isSideBarOpened: $isSideBarOpened )
                        menuLink(icon: "books.vertical.fill", text: "መዝሙር", isSideBarOpened: $isSideBarOpened )
                        menuLink(icon: "bookmark", text: "አንገርጋሪ", isSideBarOpened: $isSideBarOpened )
                    }
                    
                    Divider()
                        .background(Color.green.opacity(0.5))
                    
                    VStack(alignment: .leading, spacing: 5) {
                        navigationLink(icon: "wrench.and.screwdriver.fill", text: "መዋቅር", content: ContentView())
                        navigationLink(icon: "star.fill", text: "ያግኙን", content: ContentView())
                    }
                }
                .padding(.top, 100)
                .padding(.horizontal, 30)
            }
            .frame(width: sideBarWidth)
            .offset(x: isSideBarOpened ? 0 : -sideBarWidth)
            .animation(.default, value: isSideBarOpened)

            Spacer()
        }
    }

    private var MenuChevron: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 18)
                .fill(Color(.secondarySystemBackground))
                .frame(width: 60, height: 60)
                .rotationEffect(Angle(degrees: 45))
                .offset(x:-18)
                .onTapGesture {
                    isSideBarOpened.toggle()
                }
            
            Image(systemName: "chevron.left")
                .foregroundColor(.accentColor)
        }
        .opacity(isSideBarOpened ? 1 : 0)
        .offset(x: sideBarWidth / 2, y: 90)
        .animation(.default, value: isSideBarOpened)
    }

    private var userProfile: some View {
        VStack(alignment: .leading) {
            HStack {
                Image("gitsawe")
                    .resizable()
                    .clipShape(Circle())
                    .frame(width: 60, height: 60, alignment: .center)
                    .padding(.trailing, 10)
                    //.colorInvert()
                    .blendMode( .difference ) // .exclusion / .difference / .sourceAtop
                
                
                VStack(alignment: .leading, spacing: 0) {
                    Text("ግጻዌ")
                        .bold()
                        .font(Font.custom("AbyssinicaSIL-Regular", size: 25))
                    Text("ዘኦርቶዶክስ ተዋህዶ")
                        .font(.caption)
                }
            }
            .padding(.bottom, 20)
            .onTapGesture {
                isSideBarOpened.toggle()
            }
        }
    }
    
    struct navigationLink<Content: View>: View {
        var icon: String
        var text: String
        var content: Content
        var toggle: Bool = false;
        
        var body: some View {

            NavigationLink(destination: content, label: {
                HStack {
                    Group{
                        Image(systemName: icon)
                            .foregroundColor(.accentColor)
                    }
                    .frame(width: 40, alignment: .leading)

                    Text(text)
                        .font(.body)

                    Spacer()
                }
                .padding(.vertical, 15)
                .padding(.leading, 8)
                .contentShape(Rectangle()) //allows click on transparent area;
            })
            .buttonStyle(.plain)

        }
    }
    
    struct menuLink: View {
        var icon: String
        var text: String
        
        @Binding var isSideBarOpened: Bool
        
        var body: some View {
            HStack {
                Group{
                    Image(systemName: icon)
                        .foregroundColor(.accentColor)
                }
                .frame(width: 40, alignment: .leading)

                Text(text)
                    .font(.body)

                Spacer()
            }
            .padding(.vertical, 15)
            .padding(.leading, 8)
            .contentShape(Rectangle()) //allows click on transparent area;
            .onTapGesture {
                isSideBarOpened = false;
            }
            .buttonStyle(.plain)

        }
    }

}


struct LazyView<Content: View>: View {
    let build: () -> Content
    init(_ build: @autoclosure @escaping () -> Content) {
        self.build = build
    }
    var body: Content {
        build()
    }
}
//
//#if DEBUG
//struct Sidebar_Previews: PreviewProvider {
//    static var previews: some View {
//        Sidebar()
//    }
//}
//#endif
