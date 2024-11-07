//
//  LaunchScreenView.swift
//  romantic-self
//
//  Created by 岳一扬 on 2024/9/18.
//


import SwiftUI
import AVFoundation

struct LaunchScreenView: View {
    @Binding var isLaunchScreenDone: Bool
    @State private var backgroundOpacity = 0.0
    @State private var audioPlayer: AVAudioPlayer?
    
    let backgrounds = ["sunrise", "sunset", "starry_night", "rainy_day"]
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                Image(getBackgroundImage())
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: geometry.size.width, height: geometry.size.height)
                    .opacity(backgroundOpacity)
                    .animation(.easeIn(duration: 2), value: backgroundOpacity)
                
                VStack {
                    Text("欢迎来到你的自留地")
                        .font(.largeTitle)
                        .foregroundColor(.white)
                        .padding()
                        .background(Color.black.opacity(0.5))
                        .cornerRadius(10)
                }
            }
            .edgesIgnoringSafeArea(.all)
            .onAppear {
                startAnimations()
                playLaunchSound()
                DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                    withAnimation {
                        isLaunchScreenDone = true
                    }
                }
            }
        }
    }
    
    func getBackgroundImage() -> String {
        let hour = Calendar.current.component(.hour, from: Date())
        switch hour {
        case 5...11: return backgrounds[0] // sunrise
        case 12...17: return backgrounds[1] // sunset
        case 18...21: return backgrounds[2] // starry_night
        default: return backgrounds[3] // rainy_day
        }
    }
    
    func startAnimations() {
        withAnimation {
            backgroundOpacity = 1.0
        }
    }
    
    func playLaunchSound() {
        guard let path = Bundle.main.path(forResource: "launch_sound", ofType: "mp3") else { return }
        let url = URL(fileURLWithPath: path)
        do {
            audioPlayer = try AVAudioPlayer(contentsOf: url)
            audioPlayer?.play()
        } catch {
            print("Could not play launch sound")
        }
    }
}
struct MyNavigationSplitView: View {
    @State private var selectedLink: Int?
    var body: some View {
        NavigationSplitView {
            List(0..<10, selection: $selectedLink) { number in
                NavigationLink(value: number) {
                    Label(String(number), systemImage: "number")
                }
            }
            .navigationTitle("Numbers")
        } detail: {
            switch selectedLink {
            case .none:
                Text("Nothing selected")
                    .foregroundStyle(.tertiary)
            case .some(let number):
                Text("Number " + String(number) + " selected")
            }
        }
    }
}
