import SwiftUI
import AVFoundation

struct Card: Identifiable {
    let id: Int
    let content: String
    let createdAt: Date
    let updatedAt: Date
    let audioURL: URL?
    let backgroundMusicURL: URL?
    let mood: Mood
    let isDiscussionCard: Bool
}

enum Mood: String, CaseIterable {
    case calm = "沉静"
    case contemplative = "沉思"
    case creative = "创意"
    case relaxed = "悠然"
    case introspective = "内省"
    case inspiring = "励志"
    case relaxing = "放松"
    case lonely = "孤寂"
    case artistic = "艺术"
    case nostalgic = "怀旧"
    case leisurely = "悠闲"
    case interactive = "互动"
    case slowPaced = "慢节奏"
    case dreamlike = "幻境"
    case fresh = "清新"
    case serene = "宁静"
    case fantasy = "幻想"
    case bright = "明媚"
    case quiet = "寂静"
    case tranquil = "静谧"
    case growth = "成长"
    case melancholy = "蓝调"
    case romantic = "浪漫"
    case dreamy = "梦境"
    case sentimental = "伤感"
    case peaceful = "安宁"
    case gentle = "轻柔"
    case calm2 = "平静"
    case profound = "深邃"
    case mysterious = "神秘"
    case warm = "温暖"
    case tender = "温柔"
    case hopeful = "希望"
    case philosophical = "哲理"
    case thoughtful = "哲思"
    case natural = "自然"
    
    var color: Color {
        switch self {
        case .calm, .calm2: return Color(red: 0.6, green: 0.8, blue: 1.0)
        case .contemplative, .introspective: return Color(red: 0.5, green: 0.5, blue: 0.7)
        case .creative: return Color(red: 1.0, green: 0.6, blue: 0.2)
        case .relaxed, .relaxing: return Color(red: 0.7, green: 0.9, blue: 0.7)
        case .inspiring: return Color(red: 1.0, green: 0.8, blue: 0.2)
        case .lonely: return Color(red: 0.5, green: 0.5, blue: 0.6)
        case .artistic: return Color(red: 0.8, green: 0.3, blue: 0.7)
        case .nostalgic: return Color(red: 0.9, green: 0.8, blue: 0.6)
        case .leisurely: return Color(red: 0.6, green: 0.9, blue: 0.8)
        case .interactive: return Color(red: 0.3, green: 0.8, blue: 1.0)
        case .slowPaced: return Color(red: 0.7, green: 0.7, blue: 0.8)
        case .dreamlike, .dreamy: return Color(red: 0.8, green: 0.6, blue: 1.0)
        case .fresh: return Color(red: 0.4, green: 1.0, blue: 0.8)
        case .serene: return Color(red: 0.7, green: 0.9, blue: 1.0)
        case .fantasy: return Color(red: 0.9, green: 0.5, blue: 0.9)
        case .bright: return Color(red: 1.0, green: 0.9, blue: 0.4)
        case .quiet: return Color(red: 0.8, green: 0.8, blue: 0.9)
        case .tranquil: return Color(red: 0.6, green: 0.8, blue: 0.9)
        case .growth: return Color(red: 0.5, green: 0.9, blue: 0.5)
        case .melancholy: return Color(red: 0.4, green: 0.6, blue: 0.8)
        case .romantic: return Color(red: 1.0, green: 0.6, blue: 0.8)
        case .sentimental: return Color(red: 0.9, green: 0.7, blue: 0.7)
        case .peaceful: return Color(red: 0.8, green: 1.0, blue: 0.9)
        case .gentle: return Color(red: 0.9, green: 0.8, blue: 1.0)
        case .profound: return Color(red: 0.3, green: 0.3, blue: 0.5)
        case .mysterious: return Color(red: 0.4, green: 0.3, blue: 0.5)
        case .warm: return Color(red: 1.0, green: 0.7, blue: 0.4)
        case .tender: return Color(red: 1.0, green: 0.8, blue: 0.9)
        case .hopeful: return Color(red: 0.6, green: 1.0, blue: 0.6)
        case .philosophical, .thoughtful: return Color(red: 0.5, green: 0.5, blue: 0.5)
        case .natural: return Color(red: 0.5, green: 0.8, blue: 0.5)
        }
    }
    
    var animation: Animation {
        switch self {
        case .calm, .relaxed, .serene, .peaceful, .calm2:
            return Animation.easeInOut(duration: 2).repeatForever(autoreverses: true)
        case .creative, .inspiring, .interactive, .bright:
            return Animation.spring(response: 0.5, dampingFraction: 0.5, blendDuration: 0.5).repeatForever(autoreverses: true)
        case .dreamy, .fantasy, .dreamlike:
            return Animation.easeInOut(duration: 3).repeatForever(autoreverses: true)
        case .mysterious, .philosophical, .thoughtful:
            return Animation.easeIn(duration: 2).repeatForever(autoreverses: true)
        default:
            return Animation.easeInOut(duration: 1.5).repeatForever(autoreverses: true)
        }
    }
}

class CardDataManager: ObservableObject {
    @Published var cards: [Card] = []
    
    init() {
        loadCardsFromCSV()
    }
    
    func loadCardsFromCSV() {
        guard let url = Bundle.main.url(forResource: "cards", withExtension: "csv") else {
            print("CSV file not found")
            return
        }
        
        do {
            let content = try String(contentsOf: url, encoding: .utf8)
            let rows = content.components(separatedBy: .newlines).dropFirst() // Drop header row
            
            for row in rows where !row.isEmpty {
                let columns = row.components(separatedBy: ",")
                if columns.count == 8, let card = createCard(from: columns) {
                    cards.append(card)
                }
            }
        } catch {
            print("Error reading CSV file: \(error)")
        }
    }
    
    private func createCard(from columns: [String]) -> Card? {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        
        guard let id = Int(columns[0].trimmingCharacters(in: CharacterSet(charactersIn: "\""))),
              let createdAt = dateFormatter.date(from: columns[2].trimmingCharacters(in: CharacterSet(charactersIn: "\""))),
              let updatedAt = dateFormatter.date(from: columns[3].trimmingCharacters(in: CharacterSet(charactersIn: "\""))) else {
            return nil
        }
        
        let content = columns[1].trimmingCharacters(in: CharacterSet(charactersIn: "\""))
        let audioURL = URL(string: columns[4].trimmingCharacters(in: CharacterSet(charactersIn: "\"")))
        let backgroundMusicURL = URL(string: columns[5].trimmingCharacters(in: CharacterSet(charactersIn: "\"")))
        let mood = Mood(rawValue: columns[6].trimmingCharacters(in: CharacterSet(charactersIn: "\""))) ?? .calm
        let isDiscussionCard = columns[7].trimmingCharacters(in: CharacterSet(charactersIn: "\"")) == "1"
        
        return Card(
            id: id,
            content: content,
            createdAt: createdAt,
            updatedAt: updatedAt,
            audioURL: audioURL,
            backgroundMusicURL: backgroundMusicURL,
            mood: mood,
            isDiscussionCard: isDiscussionCard
        )
    }
}

struct HomeView: View {
    @StateObject private var cardDataManager = CardDataManager()
    @State private var currentCardIndex = 0
    @State private var offset = CGSize.zero
    @State private var isNightMode = false
    @State private var rotation: Double = 0
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                backgroundView
                
                VStack {
                    if !cardDataManager.cards.isEmpty {
                        cardStack
                            .frame(maxWidth: geometry.size.width * 0.9, maxHeight: geometry.size.height * 0.75)
                            .padding(.top, 30)
                        
                        Spacer()
                        
                        controlButtons
                            .padding(.bottom, 50)
                    } else {
                        Text("No cards available")
                            .foregroundColor(.white)
                            .font(.title2)
                    }
                }
            }
        }
        .preferredColorScheme(isNightMode ? .dark : .light)
    }
    
    var backgroundView: some View {
        Group {
            if isNightMode {
                NightSkyView()
            } else {
                GradientBackgroundView(mood: currentCard?.mood ?? .calm)
            }
        }
        .animation(.easeInOut, value: isNightMode)
        .animation(.easeInOut, value: currentCard?.mood)
    }
    
    var cardStack: some View {
        ZStack {
            ForEach(0..<min(3, cardDataManager.cards.count), id: \.self) { index in
                if currentCardIndex + index < cardDataManager.cards.count {
                    CardView(card: cardDataManager.cards[currentCardIndex + index])
                        .rotationEffect(.degrees(Double(index) * 5))
                        .offset(x: index == 0 ? offset.width : 0, y: index == 0 ? offset.height : 0)
                        .scaleEffect(index == 0 ? 1 : 0.95 - CGFloat(index) * 0.05)
                        .zIndex(Double(cardDataManager.cards.count - index))
                        .rotation3DEffect(.degrees(rotation), axis: (x: 0, y: 1, z: 0))
                }
            }
        }
        .gesture(
            DragGesture()
                .onChanged { gesture in
                    offset = gesture.translation
                    rotation = Double(gesture.translation.width / 20)
                }
                .onEnded { gesture in
                    swipeCard(width: gesture.translation.width)
                }
        )
    }
    
    var controlButtons: some View {
        HStack(spacing: 40) {
            Button(action: { swipeCard(width: -500) }) {
                Text("Dislike")
                    .foregroundColor(.white)
                    .padding(.vertical, 12)
                    .padding(.horizontal, 24)
                    .background(Color.red)
                    .cornerRadius(20)
            }
            
            Button(action: { swipeCard(width: 500) }) {
                Text("Like")
                    .foregroundColor(.white)
                    .padding(.vertical, 12)
                    .padding(.horizontal, 24)
                    .background(Color.green)
                    .cornerRadius(20)
            }
        }
    }
    
    var currentCard: Card? {
        guard !cardDataManager.cards.isEmpty else { return nil }
        return cardDataManager.cards[currentCardIndex % cardDataManager.cards.count]
    }
    
    func swipeCard(width: CGFloat) {
        let swipeThreshold: CGFloat = 100
        
        withAnimation(.spring()) {
            if abs(width) > swipeThreshold {
                offset = CGSize(width: width * 2, height: 0)
                rotation = Double(width / 10)
                moveToNextCard()
            } else {
                offset = .zero
                rotation = 0
            }
        }
    }
    
    func moveToNextCard() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            guard !cardDataManager.cards.isEmpty else { return }
            currentCardIndex = (currentCardIndex + 1) % cardDataManager.cards.count
            offset = .zero
            rotation = 0
        }
    }
}

struct CardView: View {
    let card: Card
    @State private var isFlipped = false
    @State private var fadeIn = false
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 20)
                .fill(Color.white)
                .shadow(radius: 10)
                .rotation3DEffect(
                    .degrees(isFlipped ? 180 : 0),
                    axis: (x: 0.0, y: 1.0, z: 0.0)
                )
            
            if isFlipped {
                cardBack
                    .rotation3DEffect(
                        .degrees(180),
                        axis: (x: 0.0, y: 1.0, z: 0.0)
                    )
            } else {
                cardFront
            }
        }
        .frame(width: 320, height: 480)
        .animation(.spring(response: 0.6, dampingFraction: 0.8, blendDuration: 0))
        .onTapGesture {
            withAnimation(.spring(response: 0.6, dampingFraction: 0.8, blendDuration: 0)) {
                isFlipped.toggle()
            }
        }
        .onAppear {
            withAnimation(.easeIn(duration: 0.5)) {
                fadeIn = true
            }
        }
    }
    
    var cardFront: some View {
        VStack(spacing: 20) {
            Spacer()
            
            Text(card.content.trimmingCharacters(in: .whitespacesAndNewlines))
                .font(.title2)
                .multilineTextAlignment(.center)
                .foregroundColor(.black)
                .padding(.horizontal, 20)
                .opacity(fadeIn ? 1 : 0)
            
            Spacer()
            
            HStack {
                Text(card.mood.rawValue)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(card.mood.color.opacity(0.2))
                    .cornerRadius(15)
                
                if card.isDiscussionCard {
                    Text("讨论")
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(Color.blue.opacity(0.2))
                        .cornerRadius(15)
                }
            }
            .padding(.bottom, 30)
            .opacity(fadeIn ? 1 : 0)
        }
    }
    
    var cardBack: some View {
        VStack(spacing: 20) {
            Text("Card Details")
                .font(.title)
                .fontWeight(.bold)
                .padding(.top, 30)
            
            VStack(alignment: .leading, spacing: 10) {
                Text("Created: \(formattedDate(card.createdAt))")
                Text("Updated: \(formattedDate(card.updatedAt))")
                Text("Mood: \(card.mood.rawValue)")
                Text("Discussion Card: \(card.isDiscussionCard ? "Yes" : "No")")
            }
            .padding(.horizontal, 20)
            
            Spacer()
        }
        .foregroundColor(.black)
    }
    
    func formattedDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
}

struct GradientBackgroundView: View {
    let mood: Mood
    @State private var animationPhase: CGFloat = 0
    
    var body: some View {
        ZStack {
            LinearGradient(gradient: Gradient(colors: [mood.color.opacity(0.6), mood.color.opacity(0.2)]), startPoint: .topLeading, endPoint: .bottomTrailing)
            
            GeometryReader { geometry in
                ForEach(0..<20) { _ in
                    Circle()
                        .fill(mood.color.opacity(0.2))
                        .frame(width: CGFloat.random(in: 20...100))
                        .position(
                            x: CGFloat.random(in: 0...geometry.size.width),
                            y: CGFloat.random(in: 0...geometry.size.height)
                        )
                        .animation(
                            Animation.linear(duration: Double.random(in: 5...20))
                                .repeatForever(autoreverses: false)
                        )
                }
            }
            
            GeometryReader { geometry in
                Path { path in
                    for _ in 0..<100 {
                        let x = CGFloat.random(in: 0...geometry.size.width)
                        let y = CGFloat.random(in: 0...geometry.size.height)
                        path.move(to: CGPoint(x: x, y: y))
                        path.addLine(to: CGPoint(x: x + 1, y: y + 1))
                    }
                }
                .stroke(Color.white.opacity(0.2), lineWidth: 1)
                .animation(mood.animation)
            }
        }
        .edgesIgnoringSafeArea(.all)
        .onAppear {
            withAnimation(mood.animation) {
                animationPhase = 1
            }
        }
    }
}

struct NightSkyView: View {
    @State private var starOpacity: Double = 0
    
    var body: some View {
        ZStack {
            Color.black.edgesIgnoringSafeArea(.all)
            
            GeometryReader { geometry in
                ForEach(0..<100) { _ in
                    Circle()
                        .fill(Color.white)
                        .frame(width: CGFloat.random(in: 1...3), height: CGFloat.random(in: 1...3))
                        .position(
                            x: CGFloat.random(in: 0...geometry.size.width),
                            y: CGFloat.random(in: 0...geometry.size.height)
                        )
                        .opacity(starOpacity)
                        .animation(
                            Animation.easeInOut(duration: Double.random(in: 1...3))
                                .repeatForever(autoreverses: true)
                        )
                }
            }
        }
        .onAppear {
            withAnimation(.easeIn(duration: 2)) {
                starOpacity = 1
            }
        }
    }
}

// 音频播放相关代码已被注释
/*
class AudioPlayer: ObservableObject {
    private var audioPlayer: AVAudioPlayer?
    
    func playBackgroundMusic(url: URL) {
        playAudio(from: url)
    }
    
    func playCardMoveSound(url: URL) {
        playAudio(from: url)
    }
    
    private func playAudio(from url: URL) {
        do {
            audioPlayer = try AVAudioPlayer(contentsOf: url)
            audioPlayer?.play()
        } catch {
            print("Failed to play audio: \(error)")
        }
    }
}
*/
