//
//  ProfileView.swift
//  romantic-self
//
//  Created by 岳一扬 on 2024/9/18.
//


import SwiftUI

struct ProfileView: View {
    @State private var username = "用户名"
    @State private var showingSettings = false
    
    var body: some View {
        NavigationView {
            List {
                VStack(alignment: .center) {
                    Image(systemName: "person.circle.fill")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 100, height: 100)
                        .foregroundColor(.blue)
                    
                    Text(username)
                        .font(.title)
                    
                    Text("这里是个人简介")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                }
                .frame(maxWidth: .infinity)
                .padding()
                
                Section(header: Text("收藏夹")) {
                    ForEach(1...5, id: \.self) { item in
                        Text("收藏项目 \(item)")
                    }
                }
                
                Section(header: Text("我发布的")) {
                    ForEach(1...5, id: \.self) { item in
                        Text("发布内容 \(item)")
                    }
                }
            }
            .listStyle(InsetGroupedListStyle())
            .navigationTitle("小窝")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { showingSettings = true }) {
                        Image(systemName: "gearshape")
                    }
                }
            }
            .sheet(isPresented: $showingSettings) {
                SettingsView()
            }
        }
    }
}

struct SettingsView: View {
    var body: some View {
        NavigationView {
            List {
                Section(header: Text("账户设置")) {
                    Text("修改个人信息")
                    Text("隐私设置")
                    Text("通知设置")
                }
                
                Section(header: Text("应用设置")) {
                    Text("主题设置")
                    Text("语言设置")
                    Text("清除缓存")
                }
                
                Section {
                    Button("退出登录") {
                        // 实现退出登录逻辑
                    }
                    .foregroundColor(.red)
                }
            }
            .navigationTitle("设置")
        }
    }
}
