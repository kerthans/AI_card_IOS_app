import SwiftUI
import Combine

// MARK: - 数据模型

/// 用户模型
struct User: Identifiable, Codable, Equatable {
    let id: UUID
    let username: String
    let avatarURL: URL?
    
    // Equatable 协议要求
    static func == (lhs: User, rhs: User) -> Bool {
        return lhs.id == rhs.id
    }
}

/// 评论模型
struct Comment: Identifiable, Codable, Equatable {
    let id: UUID
    let user: User
    let content: String
    let timestamp: Date
    
    // Equatable 协议要求
    static func == (lhs: Comment, rhs: Comment) -> Bool {
        return lhs.id == rhs.id
    }
}

/// 帖子模型
struct Post: Identifiable, Codable, Equatable {
    let id: UUID
    let user: User
    let imageURL: URL?
    let textContent: String
    let musicURL: URL?
    var likes: Int
    var comments: [Comment]
    var isCollected: Bool
    var isPublic: Bool
    let timestamp: Date
    
    // Equatable 协议要求
    static func == (lhs: Post, rhs: Post) -> Bool {
        return lhs.id == rhs.id
    }
}

// MARK: - 视图模型

class UniverseViewModel: ObservableObject {
    @Published var posts: [Post] = []  // 帖子数据
    @Published var isLoading: Bool = false  // 加载状态
    @Published var showNewPostModal: Bool = false  // 发布内容模态视图显示状态
    
    private var cancellables = Set<AnyCancellable>()
    private var currentPage: Int = 1  // 当前页码
    private let pageSize: Int = 10  // 每页加载数量
    private var canLoadMore: Bool = true  // 是否可以继续加载更多
    
    init() {
        fetchPosts()
    }
    
    /// 获取帖子数据
    /// - Parameter reset: 是否重置数据
    func fetchPosts(reset: Bool = false) {
        guard !isLoading && canLoadMore else { return }
        isLoading = true
        
        if reset {
            currentPage = 1
            canLoadMore = true
        }
        
        // 模拟网络延迟
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            // 生成模拟数据
            let newPosts = (1...self.pageSize).map { index -> Post in
                Post(
                    id: UUID(),
                    user: User(id: UUID(), username: "用户\(self.currentPage)-\(index)", avatarURL: nil),
                    imageURL: URL(string: "https://picsum.photos/400/600?random=\(self.currentPage * index)"),
                    textContent: "这是一个浪漫的故事片段，带有蓝调氛围。",
                    musicURL: nil,
                    likes: Int.random(in: 0...100),
                    comments: [],
                    isCollected: false,
                    isPublic: true,
                    timestamp: Date()
                )
            }
            
            if reset {
                self.posts = newPosts
            } else {
                self.posts += newPosts
            }
            
            self.isLoading = false
            self.currentPage += 1
            
            // 假设最多加载5页数据
            if self.currentPage > 5 {
                self.canLoadMore = false
            }
        }
    }
    
    /// 发布新帖子
    /// - Parameters:
    ///   - image: 选择的图片
    ///   - text: 输入的文字
    ///   - music: 选择的音乐URL
    ///   - isPublic: 是否公开
    func publishPost(image: UIImage?, text: String, music: URL?, isPublic: Bool) {
        // 上传图片并获取URL的逻辑应在此实现
        // 这里我们暂时忽略图片上传，直接使用选中的图片
        let imageURL: URL? = nil // 需要上传图片后获取URL
        
        // 如果有选取的图片，使用本地图片的URL或其他处理逻辑
        // 这里只是示例，实际应用中需要上传图片到服务器并获取URL
        var newPostImageURL: URL? = nil
        if let image = image {
            // 假设上传成功，并获取到一个服务器上的URL
            // 这里使用本地图片URL作为示例
            newPostImageURL = ImagePicker.getTemporaryImageURL(from: image)
        }
        
        let newPost = Post(
            id: UUID(),
            user: User(id: UUID(), username: "当前用户", avatarURL: nil),
            imageURL: newPostImageURL,
            textContent: text,
            musicURL: music,
            likes: 0,
            comments: [],
            isCollected: false,
            isPublic: isPublic,
            timestamp: Date()
        )
        
        // 将新帖子插入到顶部
        posts.insert(newPost, at: 0)
        
        // 模拟AI评论
        simulateAIComments(for: newPost)
    }
    
    /// 模拟AI评论
    /// - Parameter post: 被评论的帖子
    private func simulateAIComments(for post: Post) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            let aiComment = Comment(
                id: UUID(),
                user: User(id: UUID(), username: "AI小助手", avatarURL: nil),
                content: "非常有共鸣的内容，谢谢分享！",
                timestamp: Date()
            )
            if let index = self.posts.firstIndex(where: { $0.id == post.id }) {
                self.posts[index].comments.append(aiComment)
            }
        }
    }
    
    /// 点赞功能
    /// - Parameter post: 被点赞的帖子
    func toggleLike(for post: Post) {
        if let index = posts.firstIndex(where: { $0.id == post.id }) {
            posts[index].likes += 1
        }
    }
    
    /// 收藏功能
    /// - Parameter post: 被收藏的帖子
    func toggleCollect(for post: Post) {
        if let index = posts.firstIndex(where: { $0.id == post.id }) {
            posts[index].isCollected.toggle()
        }
    }
}

// MARK: - 视图

struct UniverseView: View {
    @StateObject private var viewModel = UniverseViewModel()  // 视图模型实例
    @State private var showingNewPostSheet = false  // 发布内容模态视图显示状态
    
    var body: some View {
        NavigationView {
            ScrollView {
                LazyVStack {
                    // 遍历展示每个帖子
                    ForEach(viewModel.posts) { post in
                        PostView(post: post, viewModel: viewModel)
                            .padding(.bottom, 20)
                            .onAppear {
                                // 无限滚动加载更多
                                if self.viewModel.posts.last == post {
                                    self.viewModel.fetchPosts()
                                }
                            }
                    }
                    
                    // 显示加载指示器
                    if viewModel.isLoading {
                        ProgressView()
                            .padding()
                    }
                }
                .padding()
            }
            .background(Color.warmBackground)  // 设置背景色
            .navigationTitle("小宇宙")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    // 发布按钮
                    Button(action: {
                        showingNewPostSheet = true
                    }) {
                        Image(systemName: "plus.circle.fill")
                            .resizable()
                            .frame(width: 30, height: 30)
                            .foregroundColor(.oceanBlue)
                    }
                }
            }
            .refreshable {
                // 下拉刷新
                viewModel.fetchPosts(reset: true)
            }
            .sheet(isPresented: $showingNewPostSheet) {
                // 发布内容模态视图
                NewPostView(viewModel: viewModel)
            }
        }
        .navigationViewStyle(StackNavigationViewStyle())  // 适配不同设备
    }
}

/// 帖子视图
struct PostView: View {
    let post: Post
    @ObservedObject var viewModel: UniverseViewModel  // 视图模型引用
    @State private var animateLike: Bool = false  // 点赞动画状态
    @State private var showComments: Bool = false  // 展开/收起评论区
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            // 用户信息
            HStack {
                Text(post.user.username)
                    .font(.headline)
                    .foregroundColor(.midnightBlue)
                Spacer()
                Text(formattedDate(post.timestamp))
                    .font(.subheadline)
                    .foregroundColor(.gray)
            }
            
            // 图片
            if let imageURL = post.imageURL {
                AsyncImage(url: imageURL) { phase in
                    switch phase {
                    case .empty:
                        ProgressView()
                            .frame(height: 300)
                    case .success(let image):
                        image
                            .resizable()
                            .scaledToFill()
                            .frame(maxWidth: .infinity)
                            .frame(height: 300)
                            .clipped()
                            .cornerRadius(15)
                            .shadow(radius: 5)
                            .transition(.scale)
                    case .failure:
                        Image(systemName: "photo")
                            .resizable()
                            .scaledToFit()
                            .frame(height: 300)
                            .foregroundColor(.gray)
                    @unknown default:
                        EmptyView()
                    }
                }
                .cornerRadius(15)
                .shadow(radius: 5)
            }
            
            // 文字内容
            Text(post.textContent)
                .font(.body)
                .foregroundColor(.midnightBlue)
                .padding(.horizontal, 5)
                .transition(.opacity)
            
            // 互动按钮
            HStack {
                // 点赞按钮
                Button(action: {
                    withAnimation(.spring()) {
                        viewModel.toggleLike(for: post)
                        animateLike = true
                        // 取消动画状态
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                            animateLike = false
                        }
                    }
                }) {
                    HStack {
                        Image(systemName: "heart.fill")
                            .foregroundColor(animateLike ? .red : .gray)
                            .scaleEffect(animateLike ? 1.5 : 1.0)
                            .animation(.easeInOut(duration: 0.3), value: animateLike)
                        Text("\(post.likes)")
                            .foregroundColor(.midnightBlue)
                    }
                }
                
                Spacer()
                
                // 评论按钮
                Button(action: {
                    withAnimation {
                        showComments.toggle()
                    }
                }) {
                    HStack {
                        Image(systemName: "bubble.right")
                            .foregroundColor(.gray)
                        Text("\(post.comments.count)")
                            .foregroundColor(.midnightBlue)
                    }
                }
                
                Spacer()
                
                // 收藏按钮
                Button(action: {
                    withAnimation {
                        viewModel.toggleCollect(for: post)
                    }
                }) {
                    Image(systemName: post.isCollected ? "bookmark.fill" : "bookmark")
                        .foregroundColor(post.isCollected ? .goldenGlow : .gray)
                        .scaleEffect(post.isCollected ? 1.2 : 1.0)
                        .animation(.easeInOut(duration: 0.3), value: post.isCollected)
                }
            }
            .font(.subheadline)
            .padding(.horizontal, 5)
            
            // 评论区
            if showComments && !post.comments.isEmpty {
                ForEach(post.comments) { comment in
                    CommentView(comment: comment)
                        .transition(.slide)
                }
            }
        }
        .padding()
        .background(Color.fogWhite)
        .cornerRadius(20)
        .shadow(color: Color.charcoalGray.opacity(0.1), radius: 10, x: 0, y: 5)
        .onTapGesture {
            // 点击帖子可以展开详情或其他操作
        }
    }
    
    /// 格式化日期
    /// - Parameter date: Date类型日期
    /// - Returns: 格式化后的字符串
    private func formattedDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        return formatter.string(from: date)
    }
}

/// 评论视图
struct CommentView: View {
    let comment: Comment
    
    var body: some View {
        HStack(alignment: .top, spacing: 5) {
            Text(comment.user.username)
                .font(.caption)
                .bold()
                .foregroundColor(.oceanBlue)
            Text(comment.content)
                .font(.caption)
                .foregroundColor(.gray)
            Spacer()
            Text(timeAgo(from: comment.timestamp))
                .font(.caption2)
                .foregroundColor(.gray)
        }
        .padding(.horizontal, 10)
    }
    
    /// 计算时间差
    /// - Parameter date: Date类型日期
    /// - Returns: 时间差描述字符串
    private func timeAgo(from date: Date) -> String {
        let interval = Date().timeIntervalSince(date)
        let minutes = Int(interval / 60)
        if minutes < 60 {
            return "\(minutes)分钟前"
        } else {
            let hours = minutes / 60
            return "\(hours)小时前"
        }
    }
}

/// 发布内容视图
struct NewPostView: View {
    @Environment(\.presentationMode) var presentationMode  // 控制模态视图
    @ObservedObject var viewModel: UniverseViewModel  // 视图模型引用
    
    @State private var selectedImage: UIImage?  // 选中的图片
    @State private var inputText: String = ""  // 输入的文字
    @State private var isPublic: Bool = true  // 是否公开状态
    @State private var showingImagePicker: Bool = false  // 图片选择器显示状态
    
    var body: some View {
        NavigationView {
            VStack {
                Spacer()
                
                // 选择图片按钮
                Button(action: {
                    showingImagePicker = true
                }) {
                    if let image = selectedImage {
                        Image(uiImage: image)
                            .resizable()
                            .scaledToFill()
                            .frame(width: 250, height: 250)
                            .clipped()
                            .cornerRadius(20)
                            .shadow(radius: 5)
                            .overlay(
                                RoundedRectangle(cornerRadius: 20)
                                    .stroke(Color.oceanBlue, lineWidth: 2)
                            )
                    } else {
                        ZStack {
                            Rectangle()
                                .fill(Color.fogWhite)
                                .frame(width: 250, height: 250)
                                .cornerRadius(20)
                                .shadow(radius: 5)
                            Image(systemName: "photo.on.rectangle.angled")
                                .font(.largeTitle)
                                .foregroundColor(.gray)
                        }
                    }
                }
                .padding()
                .sheet(isPresented: $showingImagePicker) {
                    ImagePicker(image: $selectedImage)
                }
                
                // 输入文本区域
                TextEditor(text: $inputText)
                    .frame(height: 150)
                    .padding()
                    .background(Color.fogWhite)
                    .cornerRadius(15)
                    .overlay(
                        RoundedRectangle(cornerRadius: 15)
                            .stroke(Color.charcoalGray.opacity(0.2), lineWidth: 1)
                    )
                    .padding()
                
                // 选择是否公开
                Toggle(isOn: $isPublic) {
                    Text("公开")
                        .foregroundColor(.midnightBlue)
                }
                .padding(.horizontal)
                
                Spacer()
            }
            .background(Color.warmBackground.edgesIgnoringSafeArea(.all))
            .navigationTitle("发布内容")
            .toolbar {
                // 取消按钮
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("取消") {
                        presentationMode.wrappedValue.dismiss()
                    }
                    .foregroundColor(.oceanBlue)
                }
                
                // 发布按钮
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("发布") {
                        // 发布内容
                        viewModel.publishPost(
                            image: selectedImage,
                            text: inputText,
                            music: nil, // 可扩展为音乐选择
                            isPublic: isPublic
                        )
                        presentationMode.wrappedValue.dismiss()
                    }
                    .disabled(inputText.isEmpty && selectedImage == nil)
                    .foregroundColor((inputText.isEmpty && selectedImage == nil) ? .gray : .oceanBlue)
                }
            }
        }
    }
}

// MARK: - 图片选择器

struct ImagePicker: UIViewControllerRepresentable {
    @Environment(\.presentationMode) var presentationMode  // 控制模态视图
    @Binding var image: UIImage?  // 绑定选择的图片
    
    class Coordinator: NSObject, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
        let parent: ImagePicker
        
        init(parent: ImagePicker) {
            self.parent = parent
        }
        
        /// 选择图片后的回调
        func imagePickerController(
            _ picker: UIImagePickerController,
            didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]
        ) {
            if let uiImage = info[.originalImage] as? UIImage {
                parent.image = uiImage
            }
            parent.presentationMode.wrappedValue.dismiss()
        }
    }
    
    /// 创建协调器
    func makeCoordinator() -> Coordinator {
        Coordinator(parent: self)
    }
    
    /// 创建UIImagePickerController
    func makeUIViewController(context: Context) -> some UIViewController {
        let picker = UIImagePickerController()
        picker.delegate = context.coordinator
        picker.sourceType = .photoLibrary
        picker.allowsEditing = false
        return picker
    }
    
    /// 更新UIViewController
    func updateUIViewController(_ uiViewController: UIViewControllerType, context: Context) {}
    
    /// 获取临时图片URL（模拟上传后的URL）
    static func getTemporaryImageURL(from image: UIImage) -> URL? {
        // 此处应上传图片到服务器，并返回图片的URL
        // 这里只是将图片保存到临时文件夹，并返回URL
        let tempDirectory = FileManager.default.temporaryDirectory
        let fileName = UUID().uuidString + ".png"
        let fileURL = tempDirectory.appendingPathComponent(fileName)
        if let data = image.pngData() {
            try? data.write(to: fileURL)
            return fileURL
        }
        return nil
    }
}

// MARK: - 预览

struct UniverseView_Previews: PreviewProvider {
    static var previews: some View {
        UniverseView()
    }
}
