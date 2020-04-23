//
//  PlayButtonView.swift
//  MusicPlayer
//
//  Created by Yongkun Li on 4/19/20.
//  Copyright © 2020 Yongkun Li. All rights reserved.
//

import SwiftUI
import AVKit

struct PlayButtonView: View {
    @EnvironmentObject var PM:PlayerManager
    @State var playButtonOffset = CGSize.zero
    @Binding var stylusPos:CGPoint
    
    var body: some View {
        GeometryReader{ geo in
            HStack(spacing: 0){
                // last song
                ZStack(alignment:.trailing){
                    Rectangle()
                        .foregroundColor(.blue)
                        .frame(width: geo.size.width)
                    Image(systemName: "backward.fill")
                        .resizable()
                        .scaledToFit()
                        .padding()
                }
                // play button
                ZStack{
                    Rectangle()
                        .foregroundColor(.red)
                        .frame(width: geo.size.width)
                    Image(systemName: self.PM.isPlaying ? "pause.fill":"play.fill")
                        .resizable()
                        .scaledToFit()
                        .padding()
                }
                // next song
                ZStack(alignment:.leading){
                    Rectangle()
                        .foregroundColor(.blue)
                        .frame(width: geo.size.width)
                    Image(systemName: "forward.fill")
                        .resizable()
                        .scaledToFit()
                        .padding()
                }
            }.edgesIgnoringSafeArea(.horizontal)
        }
        .onTapGesture {
            self.PM.isPlaying.toggle()
            if self.PM.isPlaying {self.PM.player.play()}
            else {self.PM.player.pause()}
            // update stylus position in parallel
            DispatchQueue.global(qos: .background).async {
                while self.PM.isPlaying {
                    self.stylusPos.x = self.PM.timeForLabel + 25
                }
            }
        }
        .gesture(DragGesture(minimumDistance: 0, coordinateSpace: .global)
        .onChanged{ value in
            self.playButtonOffset = value.translation
        }
        .onEnded{ value in
            if self.playButtonOffset.width < -100 {
                self.PM.debugSongs.index += 1
                if self.PM.debugSongs.index >= self.PM.debugSongs.songList.count {self.PM.debugSongs.index = 0}
                self.PM.player.stop()
                self.PM.getData()
                if self.PM.isPlaying {self.PM.player.play()}
            }else if self.playButtonOffset.width > 100 {
                self.PM.debugSongs.index -= 1
                if self.PM.debugSongs.index < 0 {self.PM.debugSongs.index = self.PM.debugSongs.songList.count-1}
                self.PM.player.stop()
                self.PM.getData()
                if self.PM.isPlaying {self.PM.player.play()}
            }
            self.playButtonOffset = .zero
            }
        )
            .offset(x: self.playButtonOffset.width)
            .animation(.linear)
    }
}
