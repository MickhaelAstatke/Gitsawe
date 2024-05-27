//
//  ContentView.swift
//  Gitsawe
//
//  Created by Fekadesilassie on 12/27/23.
//

import SwiftUI

struct ContentView: View {
    
    @State var month = 1;
    @State var dayTab = 1;
    
    @State private var showPlayer: Bool = false;
    @State private var miniPlayerHeight: CGFloat = 50;
    @State private var mainPlayerHeight: CGFloat = 90;
    @State private var currentPresentationDetent: PresentationDetent =  .height(50)
    
    @State private var currentPage: Date = .now
    @StateObject var handler: AudioHandler = AudioHandler()
    
    @State private var expandSheet: Bool = false
    @State private var showSidebar: Bool = false
    @Namespace private var animation
    
    var body: some View {
        VStack {
            HStack(alignment:.center){
                Button {
                    withAnimation(.easeInOut(duration: 0.3)) {
                        showSidebar = true
                    }
                } label: {
                    Image(systemName: "line.3.horizontal")
                        .font(.title.bold())
                }
                .buttonStyle(.plain)
                
                
                
                Text("ግጻዌ")
                    .minimumScaleFactor(0.8)
                    .font(Font.custom("AbyssinicaSIL-Regular", size: 28) )
                
                Spacer()
                
                HStack(spacing: 7){
                    Text(Formatter.ethMonth.string(from: currentPage))
                        .minimumScaleFactor(0.8)
                        .font(Font.custom("AbyssinicaSIL-Regular", size: 23) )
                    
                    Text(Formatter.ethDDYYY.string(from: currentPage))
                        .minimumScaleFactor(0.8)
                        .font(.system(size: 21).bold())
                    
                    Image(systemName: "chevron.down")
                        .foregroundColor(.accentColor)
                        .font(.system(size: 21).bold())
                }
                .foregroundColor(.accentColor)
                .overlay {
                    DatePicker(
                        selection: $currentPage,
                        displayedComponents: .date
                    ){}
                        .environment(\.calendar, Calendar.init(identifier: Calendar.Identifier.ethiopicAmeteMihret ))
                        .datePickerStyle( CompactDatePickerStyle() )
                        .environment(\.locale, Locale.init(identifier: "amh"))
                        .opacity(0.011) // Minimum that still allows this to be tappable
                }
            }
            .padding(.horizontal)
            .padding(.vertical, 7)
            
            Divider()
            
            PagedInfiniteScrollView(content: { index in
                ScrollView{
                    Page(date: index, audioPlayer: handler)
                        .ignoresSafeArea()
                        .environmentObject(handler)
                        .padding(.vertical, 5)
                }
            }, currentPage: $currentPage)
        }
        .safeAreaInset(edge: .bottom) {
            CustomBottomSheet()
                .environmentObject(handler)
                .background(.green.opacity(0.2))
                .ignoresSafeArea()
        }
        .overlay {
            if expandSheet {
                ExpandedBottomSheet(expandSheet: $expandSheet, animation: animation)
                    .environmentObject(handler)
                    .transition(.asymmetric(insertion: .identity, removal: .offset(y: -5)))
            }
        }
        .overlay {
//            if showSidebar {
                Sidebar(isSideBarOpened: $showSidebar)
                    .environmentObject(handler)
                    //.transition(.asymmetric(insertion: .identity, removal: .offset(y: -5)))
//            }
        }
    
        .edgesIgnoringSafeArea(.bottom)
        .background(Color(.systemBackground))
        .animation(.easeOut, value: showPlayer)
        .animation(.easeOut, value: expandSheet)
        .animation(.easeOut, value: showSidebar)
    }
    
    
    /// Custom Bottom Sheet
    @ViewBuilder
    func CustomBottomSheet() -> some View {
        /// Animating Sheet Background (To Look Like It's Expanding From the Bottom)
        ZStack(alignment:.topLeading) {
            if expandSheet {
                Rectangle()
                    .fill(.clear)
            } else {
                Rectangle()
                    .fill(.ultraThickMaterial)
                    .overlay {
                        /// Music Info
                        MusicInfo(expandSheet: $expandSheet, animation: animation)
                    }
                    .matchedGeometryEffect(id: "BGVIEW", in: animation)
            }
        }
        .frame(height: 90)
        /// Separator Line
        .overlay(alignment: .bottom, content: {
            Rectangle()
                .fill(.gray.opacity(0.3))
                .frame(height: 1)
        })
        /// 49: Default Tab Bar Height
    //    .offset(y: -49)
    }
}

#Preview {
    ContentView()
}







/// Resuable File
struct MusicInfo: View {
    @Binding var expandSheet: Bool
    @EnvironmentObject var ap: AudioHandler;
    
    var animation: Namespace.ID
    var body: some View {
        HStack(spacing: 0) {
            /// Adding Matched Geometry Effect (Hero Animation)
            ZStack {
                if !expandSheet {
                    GeometryReader {
                        let size = $0.size
                        
                        Image("Artwork")
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(width: size.width, height: size.height)
                            .clipShape(RoundedRectangle(cornerRadius: expandSheet ? 15 : 5, style: .continuous))
                    }
                    .matchedGeometryEffect(id: "ARTWORK", in: animation)
                }
            }
            .frame(width: 45, height: 45)
            
            Text(ap.currentTrack?.title ?? "-")
                .fontWeight(.semibold)
                .lineLimit(1)
                .padding(.horizontal, 15)
            
            Spacer(minLength: 0)
            
            Button {
                ap.togglePlayPause()
            } label: {
                Image(systemName: ap.state == .playing ? "pause.fill": "play.fill")
                    .font(.title2)
            }
            .buttonStyle(.plain)
            
            Button {
                ap.skip(by: 15)
            } label: {
                Image(systemName: "goforward.15")
                    .font(.title2)
            }
            .padding(.leading, 25)
            .buttonStyle(.plain)
        }
        .foregroundColor(.primary)
        .padding(.horizontal)
        .padding(.bottom, 5)
        .frame(height: 70)
        .contentShape(Rectangle())
        .onTapGesture {
            /// Expanding Bottom Sheet
            withAnimation(.easeInOut(duration: 0.3)) {
                expandSheet = true
            }
        }
    }
}
