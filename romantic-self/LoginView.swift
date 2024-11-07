//import SwiftUI
//import Foundation
//
//struct LoginView: View {
//    @ObservedObject var appState: AppState
//    @State private var username = ""
//    @State private var password = ""
//    @State private var email = ""
//    @State private var phoneNumber = ""
//    @State private var isRegistering = false
//    @State private var showAlert = false
//    @State private var alertMessage = ""
//    @State private var currentPosterIndex = 0
//    
//    let posters = ["poster1", "poster2", "poster3"] // 替换为您的海报图片名称
//    
//    var body: some View {
//        GeometryReader { geometry in
//            VStack {
//                // 动态海报
//                TabView(selection: $currentPosterIndex) {
//                    ForEach(0..<posters.count, id: \.self) { index in
//                        Image(posters[index])
//                            .resizable()
//                            .aspectRatio(contentMode: .fill)
//                            .tag(index)
//                    }
//                }
//                .tabViewStyle(PageTabViewStyle(indexDisplayMode: .automatic))
//                .frame(height: geometry.size.height * 0.4)
//                
//                Spacer()
//                
//                // 登录/注册表单
//                VStack(spacing: 20) {
//                    TextField("用户名", text: $username)
//                        .textFieldStyle(RoundedBorderTextFieldStyle())
//                    
//                    SecureField("密码", text: $password)
//                        .textFieldStyle(RoundedBorderTextFieldStyle())
//                    
//                    if isRegistering {
//                        TextField("邮箱", text: $email)
//                            .textFieldStyle(RoundedBorderTextFieldStyle())
//                        
//                        TextField("电话号码", text: $phoneNumber)
//                            .textFieldStyle(RoundedBorderTextFieldStyle())
//                    }
//                    
//                    Button(action: isRegistering ? register : login) {
//                        Text(isRegistering ? "注册" : "登录")
//                            .frame(maxWidth: .infinity)
//                            .padding()
//                            .background(Color.blue)
//                            .foregroundColor(.white)
//                            .cornerRadius(10)
//                    }
//                    
//                    Button(action: { isRegistering.toggle() }) {
//                        Text(isRegistering ? "已有账号？点击登录" : "没有账号？点击注册")
//                            .foregroundColor(.blue)
//                    }
//                }
//                .padding()
//                .background(Color.white.opacity(0.8))
//                .cornerRadius(20)
//                .padding(.horizontal)
//                
//                Spacer()
//            }
//            .background(Color.gray.opacity(0.1).edgesIgnoringSafeArea(.all))
//        }
//        .alert(isPresented: $showAlert) {
//            Alert(title: Text("提示"), message: Text(alertMessage), dismissButton: .default(Text("确定")))
//        }
//    }
//    
//    func login() {
//        let url = URL(string: "http://120.79.144.72:5000/login")!
//        var request = URLRequest(url: url)
//        request.httpMethod = "POST"
//        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
//        
//        let body: [String: Any] = ["username": username, "password": password]
//        request.httpBody = try? JSONSerialization.data(withJSONObject: body)
//        
//        URLSession.shared.dataTask(with: request) { data, response, error in
//            if let data = data {
//                if let result = try? JSONDecoder().decode(LoginResponse.self, from: data) {
//                    DispatchQueue.main.async {
//                        if let token = result.token {
//                            UserDefaults.standard.set(token, forKey: "userToken")
//                            UserDefaults.standard.set(true, forKey: "isLoggedIn")
//                            appState.isLoggedIn = true
//                        } else {
//                            alertMessage = "登录失败：\(result.message ?? "未知错误")"
//                            showAlert = true
//                        }
//                    }
//                }
//            } else {
//                DispatchQueue.main.async {
//                    alertMessage = "登录失败：网络错误"
//                    showAlert = true
//                }
//            }
//        }.resume()
//    }
//    
//    func register() {
//        let url = URL(string: "http://120.79.144.72:5000/register")!
//        var request = URLRequest(url: url)
//        request.httpMethod = "POST"
//        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
//        
//        let body: [String: Any] = [
//            "username": username,
//            "password": password,
//            "email": email,
//            "phone_number": phoneNumber
//        ]
//        request.httpBody = try? JSONSerialization.data(withJSONObject: body)
//        
//        URLSession.shared.dataTask(with: request) { data, response, error in
//            if let data = data {
//                if let result = try? JSONDecoder().decode(RegisterResponse.self, from: data) {
//                    DispatchQueue.main.async {
//                        if result.success {
//                            alertMessage = "注册成功，请登录"
//                            isRegistering = false
//                        } else {
//                            alertMessage = "注册失败：\(result.message ?? "未知错误")"
//                        }
//                        showAlert = true
//                    }
//                }
//            } else {
//                DispatchQueue.main.async {
//                    alertMessage = "注册失败：网络错误"
//                    showAlert = true
//                }
//            }
//        }.resume()
//    }
//}
//
//struct LoginResponse: Codable {
//    let token: String?
//    let message: String?
//}
//
//struct RegisterResponse: Codable {
//    let success: Bool
//    let message: String?
//}
