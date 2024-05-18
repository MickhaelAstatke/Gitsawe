//
//  LargePlayerView.swift
//  Gitsawe
//
//  Created by Fekadesilassie on 5/16/24.
//

import SwiftUI

struct ExpandedBottomSheet: View {
    @EnvironmentObject var ap: AudioHandler;
    @Binding var expandSheet: Bool
    var animation: Namespace.ID
    /// View Properties
    @State private var animateContent: Bool = false
    @State private var offsetY: CGFloat = 0
    var body: some View {
        GeometryReader {
            let size = $0.size
            let safeArea = $0.safeAreaInsets
            let dragProgress = 1.0 - (offsetY / (size.height * 0.5))
            let cornerProgress = max(0, dragProgress)
            
            ZStack {
                /// Making it as Rounded Rectangle with Device Corner Radius
                RoundedRectangle(cornerRadius: animateContent ? deviceCornerRadius * cornerProgress : 0, style: .continuous)
                    .fill(.ultraThickMaterial)
                    .overlay(content: {
                        RoundedRectangle(cornerRadius: animateContent ? deviceCornerRadius * cornerProgress : 0, style: .continuous)
                            .fill(Color("BG"))
                            .opacity(animateContent ? 1 : 0)
                    })
                    .overlay(alignment: .top) {
                        MusicInfo(expandSheet: $expandSheet, animation: animation)
                        /// Disabling Interaction (Since it's not Necessary Here)
                            .allowsHitTesting(false)
                            .opacity(animateContent ? 0 : 1)
                    }
                    .matchedGeometryEffect(id: "BGVIEW", in: animation)
                
                
                VStack(spacing: 15) {
                    /// Grab Indicator
                    Capsule()
                        .fill(.gray)
                        .frame(width: 40, height: 5)
                        .opacity(animateContent ? cornerProgress : 0)
                        /// Mathing with Slide Animation
                        .offset(y: animateContent ? 0 : size.height)
                        .clipped()
                        .padding(.top, size.height * 0.05)
                    
                    /// Artwork Hero View
                    GeometryReader {
                        let size = $0.size
                        
                        Image("Artwork")
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(width: size.width, height: size.height)
                            .clipShape(RoundedRectangle(cornerRadius: animateContent ? 15 : 5, style: .continuous))
                    }
                    .matchedGeometryEffect(id: "ARTWORK", in: animation)
                    /// For Square Artwork Image
                    .frame(height: size.width - 50)
                    /// For Smaller Devices the padding will be 10 and for larger devices the padding will be 30
                    //.padding(.vertical, size.height < 700 ? 10 : 30)
                    .padding(.top, size.height * 0.02)
                    .padding(.bottom, size.height * 0.04)
                    
                    /// Player View
                    PlayerView(size)
                    /// Moving it From Bottom
                        .offset(y: animateContent ? 0 : size.height)
                }
                .padding(.top, safeArea.top + (safeArea.bottom == 0 ? 10 : 0))
                .padding(.bottom, safeArea.bottom == 0 ? 10 : safeArea.bottom)
                .padding(.horizontal, 25)
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
                .clipped()
            }
            .contentShape(Rectangle())
            .offset(y: offsetY)
            .gesture(
                DragGesture()
                    .onChanged({ value in
                        let translationY = value.translation.height
                        offsetY = (translationY > 0 ? translationY : 0)
                    }).onEnded({ value in
                        withAnimation(.easeInOut(duration: 0.3)) {
                            if (offsetY + (value.velocity.height * 0.3)) > size.height * 0.3 {
                                expandSheet = false
                                animateContent = false
                            } else {
                                offsetY = .zero
                            }
                        }
                    })
            )
            .ignoresSafeArea(.container, edges: .all)
        }
        .onAppear {
            withAnimation(.easeInOut(duration: 0.35)) {
                animateContent = true
            }
        }
    }
    
    /// Player View (containing all the song information with playback controls)
    @ViewBuilder
    func PlayerView(_ mainSize: CGSize) -> some View {
        GeometryReader {
            let size = $0.size
            /// Dynamic Spacing Using Available Height
            let spacing = size.height * 0.04
            
            /// Sizing it for more compact look
            VStack(spacing: spacing) {
                VStack(spacing: spacing) {
                    HStack(alignment: .center, spacing: 15) {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(ap.currentTrack?.title ?? "-")
                                .font(.title3)
                                .fontWeight(.semibold)
                                .foregroundColor(.white)
                            
                            Text("Taylor Swift")
                                .foregroundColor(.gray)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        
                        Button {
                            
                        } label: {
                            Image(systemName: "ellipsis")
                                .foregroundColor(.white)
                                .padding(12)
                                .background {
                                    Circle()
                                        .fill(.ultraThinMaterial)
                                        .environment(\.colorScheme, .light)
                                }
                        }
                        .buttonStyle(.plain)

                    }
                    
                    /// Timing Indicator
                    Capsule()
                        .fill(.ultraThinMaterial)
                        .environment(\.colorScheme, .light)
                        .frame(height: 5)
                        .padding(.top, spacing)
                    
                    /// Timing Label View
                    HStack {
                        Text("0:00")
                            .font(.caption)
                            .foregroundColor(.gray)
                        
                        Spacer(minLength: 0)
                        
                        Text("3:33")
                            .font(.caption)
                            .foregroundColor(.gray)
                    }
                    
                    /// Playback Controls
                    HStack(spacing: size.width * 0.18) {
                        Button {
                            ap.skip(by: 15)
                        } label: {
                            Image(systemName: "gobackward.15")
                            /// Dynamic Sizing for Smaller to Larger iPhones
                                .font(size.height < 300 ? .title3 : .title)
                        }
                        .buttonStyle(.plain)
                        
                        /// Making Play/Pause Little Bigger
                        Button {
                            ap.togglePlayPause()
                        } label: {
                            Image(systemName: ap.state == .playing ? "pause.fill": "play.fill")
                            /// Dynamic Sizing for Smaller to Larger iPhones
                                .font(size.height < 300 ? .largeTitle : .system(size: 50))
                        }
                        .buttonStyle(.plain)
                        
                        Button {
                            ap.skip(by: 15)
                        } label: {
                            Image(systemName: "goforward.15")
                            /// Dynamic Sizing for Smaller to Larger iPhones
                                .font(size.height < 300 ? .title3 : .title)
                        }
                        .buttonStyle(.plain)
                    }
                    .foregroundColor(.white)
                    .padding(.vertical, spacing)
//                    .frame(maxHeight: .infinity)
                    
                    
                    HStack(alignment: .top, spacing: size.width * 0.18) {
                        Button {
                            
                        } label: {
                            Image(systemName: "quote.bubble")
                                .font(.title2)
                        }
                        .buttonStyle(.plain)
                        
                        VStack(spacing: 6) {
                            Button {
                                
                            } label: {
                                Image(systemName: "airpods.gen3")
                                    .font(.title2)
                            }
                            .buttonStyle(.plain)
                            
                            Text("iJustine's Airpods")
                                .font(.caption)
                        }
                        
                        Button {
                            
                        } label: {
                            Image(systemName: "list.bullet")
                                .font(.title2)
                        }
                        .buttonStyle(.plain)
                    }
                    .foregroundColor(.white)
                    .blendMode(.overlay)
                    .padding(.top, spacing)
                }
                
            }
        }
    }
}

struct ExpandedBottomSheet_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .preferredColorScheme(.dark)
    }
}
