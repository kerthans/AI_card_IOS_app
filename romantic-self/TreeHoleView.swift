import SwiftUI
import Combine
import AVFoundation

struct TreeHoleView: View {
    @StateObject private var viewModel = TreeHoleViewModel()
    @State private var isShowingEmotionPicker = false
    
    var body: some View {
        ZStack {
            // 使用 Assets 中的 warmBackground 作为背景
            Image("warmBackground")
                .resizable()
                .scaledToFill()
                .edgesIgnoringSafeArea(.all)
                .opacity(0.3)
            
            VStack(spacing: 0) {
                customNavigationBar
                messageList
                inputArea
            }
        }
        .navigationBarHidden(true)
        .alert(item: $viewModel.errorAlert) { alert in
            Alert(title: Text("错误"), message: Text(alert.message), dismissButton: .default(Text("确定")))
        }
        .onTapGesture {
            // 点击空白区域收起键盘
            UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
        }
    }
    
    private var customNavigationBar: some View {
        HStack {
            Text("浪漫树洞")
                .font(.system(size: 28, weight: .bold, design: .serif))
                .foregroundColor(.white)
                .shadow(radius: 2)
            Spacer()
            Button(action: viewModel.startNewConversation) {
                Image(systemName: "plus.circle.fill")
                    .font(.title)
                    .foregroundColor(.white)
                    .shadow(radius: 2)
            }
            .accessibilityLabel("开始新对话")
        }
        .padding()
        .background(
            LinearGradient(gradient: Gradient(colors: [Color.black.opacity(0.6), Color.black.opacity(0.4)]), startPoint: .top, endPoint: .bottom)
                .blur(radius: 10)
        )
    }
    
    private var messageList: some View {
        ScrollViewReader { proxy in
            ScrollView {
                LazyVStack(spacing: 16) {
                    ForEach(viewModel.messages) { message in
                        MessageBubble(message: message)
                            .id(message.id)
                    }
                }
                .padding()
            }
            .onChange(of: viewModel.messages) { _ in
                if let lastMessage = viewModel.messages.last {
                    withAnimation {
                        proxy.scrollTo(lastMessage.id, anchor: .bottom)
                    }
                }
            }
        }
    }
    
    private var inputArea: some View {
        VStack(spacing: 8) {
            HStack {
                Button(action: { withAnimation { isShowingEmotionPicker.toggle() } }) {
                    Image(systemName: "face.smiling")
                        .font(.title2)
                        .foregroundColor(.white)
                        .padding(8)
                        .background(Circle().fill(Color.blue.opacity(0.6)))
                }
                .accessibilityLabel("选择表情")
                
                TextField("在这里倾诉你的心声...", text: $viewModel.inputText)
                    .textFieldStyle(PlainTextFieldStyle())
                    .padding()
                    .background(Color.white.opacity(0.8))
                    .cornerRadius(20)
                    .shadow(radius: 2)
                
                Button(action: viewModel.sendMessage) {
                    Image(systemName: "arrow.up.circle.fill")
                        .font(.title2)
                        .foregroundColor(viewModel.inputText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? .gray : .blue)
                        .padding(8)
                        .background(Circle().fill(Color.blue.opacity(viewModel.inputText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? 0.3 : 0.6)))
                }
                .disabled(viewModel.inputText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                .accessibilityLabel("发送消息")
            }
            .padding(.horizontal)
            
            if isShowingEmotionPicker {
                EmotionPickerView(selectedEmotion: $viewModel.selectedEmotionTag)
                    .transition(.move(edge: .bottom))
            }
        }
        .padding(.vertical, 8)
        .background(
            LinearGradient(gradient: Gradient(colors: [Color.black.opacity(0.6), Color.black.opacity(0.4)]), startPoint: .top, endPoint: .bottom)
                .blur(radius: 10)
        )
        .animation(.spring(), value: isShowingEmotionPicker)
    }
}

class TreeHoleViewModel: NSObject, ObservableObject, URLSessionDataDelegate {
    @Published var messages: [Message] = []
    @Published var inputText = ""
    @Published var selectedEmotionTag: EmotionTag?
    @Published var errorAlert: IdentifiableError?
    
    private let apiKey = "<API密钥>" 
    private let baseURL = "https://api.deepseek.com/chat/completions" // 示例deepseek的API
    private var session: URLSession!
    private var buffer: Data = Data()
    
    // 用于处理TTS播放
    private var audioPlayer: AVAudioPlayer?
    
    override init() {
        super.init()
        let configuration = URLSessionConfiguration.default
        session = URLSession(configuration: configuration, delegate: self, delegateQueue: nil)
    }
    
    func sendMessage() {
        let trimmedText = inputText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedText.isEmpty else { return }
        
        // 添加用户消息到消息列表
        let userMessage = Message(id: UUID().uuidString, content: trimmedText, isUser: true, emotionTag: selectedEmotionTag)
        messages.append(userMessage)
        
        // 清空输入
        inputText = ""
        selectedEmotionTag = nil
        
        // 准备参数
        var parameters: [String: Any] = [
            "model": "deepseek-chat",
            "messages": buildMessages(),
            "stream": true
        ]
        
        // 创建URL请求
        guard let url = URL(string: baseURL) else { return }
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try? JSONSerialization.data(withJSONObject: parameters)
        
        // 发起请求
        let task = session.dataTask(with: request)
        task.resume()
    }
    
    private func buildMessages() -> [[String: String]] {
        var allMessages: [[String: String]] = []
        
        // 添加系统消息
        let systemMessage = ["role": "system", "content": "你是一个温暖且富有同情心的AI助手，专门倾听和安慰用户的心声。"]
        allMessages.append(systemMessage)
        
        // 添加历史消息
        for message in messages {
            let role = message.isUser ? "user" : "assistant"
            let msg = ["role": role, "content": message.content]
            allMessages.append(msg)
        }
        
        return allMessages
    }
    
    func startNewConversation() {
        messages.removeAll()
        inputText = ""
        selectedEmotionTag = nil
    }
    
    // MARK: - URLSessionDataDelegate
    
    func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive data: Data) {
        // 将收到的数据添加到缓冲区
        buffer.append(data)
        
        // 尝试将缓冲区的数据转换为字符串
        if let string = String(data: buffer, encoding: .utf8) {
            // 按照 SSE 的分隔符 "\n\n" 分割
            let events = string.components(separatedBy: "\n\n")
            
            for event in events {
                let trimmedEvent = event.trimmingCharacters(in: .whitespacesAndNewlines)
                guard trimmedEvent.hasPrefix("data:") else { continue }
                
                let jsonString = trimmedEvent.replacingOccurrences(of: "data: ", with: "")
                if jsonString.isEmpty || jsonString == "[DONE]" { continue }
                
                if let jsonData = jsonString.data(using: .utf8) {
                    do {
                        let response = try JSONDecoder().decode(DeepSeekStreamResponse.self, from: jsonData)
                        DispatchQueue.main.async {
                            self.handleStreamResponse(response)
                        }
                    } catch {
                        DispatchQueue.main.async {
                            self.errorAlert = IdentifiableError(message: "解析错误: \(error.localizedDescription)")
                        }
                    }
                }
            }
            
            // 清空缓冲区
            buffer = Data()
        }
    }
    
    func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
        if let error = error {
            DispatchQueue.main.async {
                self.errorAlert = IdentifiableError(message: error.localizedDescription)
            }
        }
    }
    
    // MARK: - Response Handling
    
    private func handleStreamResponse(_ response: DeepSeekStreamResponse) {
        guard response.choices.indices.contains(0) else { return }
        let choice = response.choices[0]
        
        switch choice.finishReason {
        case "stop":
            // 完成回复
            break
        case "none":
            // 继续接收
            break
        default:
            break
        }
        
        if let delta = choice.delta {
            if let content = delta.content {
                // 将内容添加到最后一条助手消息
                if messages.last?.isUser == false {
                    // 如果最后一条消息是助手消息，追加内容
                    var lastMessage = messages.last!
                    lastMessage.content += content
                    messages[messages.count - 1] = lastMessage
                } else {
                    // 否则，创建新的助手消息
                    let assistantMessage = Message(id: UUID().uuidString, content: content, isUser: false)
                    messages.append(assistantMessage)
                }
            }
        }
        
        // 处理 TTS 音频（如果有）
        if let audioBase64 = response.audio, !audioBase64.isEmpty {
            if let audioData = Data(base64Encoded: audioBase64) {
                playAudio(from: audioData)
            }
        }
    }
    
    private func playAudio(from data: Data) {
        do {
            audioPlayer = try AVAudioPlayer(data: data)
            audioPlayer?.play()
        } catch {
            self.errorAlert = IdentifiableError(message: "音频播放失败: \(error.localizedDescription)")
        }
    }
}

struct DeepSeekStreamResponse: Decodable {
    struct Choice: Decodable {
        struct Delta: Decodable {
            let role: String?
            let content: String?
        }
        
        let delta: Delta?
        let finishReason: String?
        
        enum CodingKeys: String, CodingKey {
            case delta
            case finishReason = "finish_reason"
        }
    }
    
    let choices: [Choice]
    let audio: String? // 假设 API 会返回音频信息
}

struct Message: Identifiable, Equatable {
    let id: String
    var content: String
    let isUser: Bool
    var emotionTag: EmotionTag?
}

enum EmotionTag: String, CaseIterable, Codable {
    case happy = "😊"
    case sad = "😢"
    case angry = "😠"
    case confused = "😕"
    case excited = "😃"
    case calm = "😌"
}

struct IdentifiableError: Identifiable {
    let id = UUID()
    let message: String
}

struct MessageBubble: View {
    let message: Message
    
    var body: some View {
        HStack {
            if message.isUser {
                Spacer()
                VStack(alignment: .trailing, spacing: 4) {
                    if let emotionTag = message.emotionTag {
                        Text(emotionTag.rawValue)
                            .font(.title3)
                    }
                    Text(message.content)
                        .padding()
                        .background(
                            LinearGradient(gradient: Gradient(colors: [Color.blue.opacity(0.6), Color.purple.opacity(0.6)]), startPoint: .topLeading, endPoint: .bottomTrailing)
                        )
                        .cornerRadius(16)
                        .foregroundColor(.white)
                        .shadow(radius: 2)
                }
            } else {
                VStack(alignment: .leading, spacing: 4) {
                    Text(message.content)
                        .padding()
                        .background(Color.gray.opacity(0.3))
                        .cornerRadius(16)
                        .foregroundColor(.black)
                        .shadow(radius: 2)
                }
                Spacer()
            }
        }
        .padding(message.isUser ? .leading : .trailing, 60)
        .transition(.opacity.animation(.easeInOut))
    }
}

struct EmotionPickerView: View {
    @Binding var selectedEmotion: EmotionTag?
    
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 16) {
                ForEach(EmotionTag.allCases, id: \.self) { emotion in
                    Button(action: {
                        selectedEmotion = emotion
                    }) {
                        Text(emotion.rawValue)
                            .font(.largeTitle)
                            .padding()
                            .background(selectedEmotion == emotion ? Color.blue.opacity(0.3) : Color.clear)
                            .cornerRadius(12)
                    }
                    .accessibilityLabel("\(emotion.rawValue) 表情")
                }
            }
            .padding(.horizontal)
        }
        .frame(height: 60)
    }
}

struct TreeHoleView_Previews: PreviewProvider {
    static var previews: some View {
        TreeHoleView()
    }
}
