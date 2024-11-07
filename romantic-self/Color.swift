import SwiftUI

// MARK: - 颜色扩展
extension Color {
    /// 薄荷蓝色
    static let mintBlue = Color(hex: "A0D8E5")
    
    /// 雾白色
    static let fogWhite = Color(hex: "F0F4F8")
    
    /// 夕阳粉
    static let sunsetPink = Color(hex: "FFC1C1")
    
    /// 黛安灰
    static let dawnGray = Color(hex: "D3D3D3")
    
    /// 金色辉光
    static let goldenGlow = Color(hex: "FFD700")
    
    /// 海洋蓝
    static let oceanBlue = Color(hex: "1E90FF")
    
    /// 森林绿
    static let forestGreen = Color(hex: "228B22")
    
    /// 淡紫色
    static let lavenderPurple = Color(hex: "E6E6FA")
    
    /// 沙滩米色
    static let sandyBeige = Color(hex: "F4A460")
    
    /// 木炭灰
    static let charcoalGray = Color(hex: "36454F")
    
    /// 深邃蓝（适合作为主题色）
    static let deepBlue = Color(hex: "1E3A8A")
    
    /// 月光银（适合作为强调色）
    static let moonlightSilver = Color(hex: "D1D5DB")
    
    /// 午夜蓝（适合作为文字颜色）
    static let midnightBlue = Color(hex: "1E40AF")
    
    /// 温暖背景色
    static let warmBackground = Color(hex: "F9F4F0")
}

// MARK: - 从十六进制初始化颜色
extension Color {
    /// 通过十六进制字符串初始化颜色
    /// - Parameter hex: 十六进制颜色字符串（例如 "FFFFFF"）
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }

        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue:  Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
    
    /// 将颜色转换为十六进制字符串
    /// - Returns: 十六进制颜色字符串（例如 "FFFFFF"）
    func toHex() -> String? {
        guard let components = UIColor(self).cgColor.components, components.count >= 3 else {
            return nil
        }
        let r = Float(components[0])
        let g = Float(components[1])
        let b = Float(components[2])
        return String(format: "%02lX%02lX%02lX", lroundf(r * 255), lroundf(g * 255), lroundf(b * 255))
    }
}

// MARK: - 颜色混合与操作
extension Color {
    /// 使颜色变亮
    /// - Parameter percentage: 增加的百分比（默认30%）
    /// - Returns: 变亮后的颜色
    func lighter(by percentage: CGFloat = 30.0) -> Color {
        return self.adjust(by: abs(percentage))
    }
    
    /// 使颜色变暗
    /// - Parameter percentage: 减少的百分比（默认30%）
    /// - Returns: 变暗后的颜色
    func darker(by percentage: CGFloat = 30.0) -> Color {
        return self.adjust(by: -1 * abs(percentage))
    }
    
    /// 调整颜色亮度
    /// - Parameter percentage: 调整的百分比
    /// - Returns: 调整后的颜色
    func adjust(by percentage: CGFloat = 30.0) -> Color {
        return Color(UIColor(self).adjust(by: percentage) ?? .black)
    }
    
    /// 获取颜色的互补色
    /// - Returns: 互补色
    func complementary() -> Color {
        guard let components = UIColor(self).cgColor.components, components.count >= 3 else {
            return self
        }
        return Color(
            red: 1 - Double(components[0]),
            green: 1 - Double(components[1]),
            blue: 1 - Double(components[2])
        )
    }
    
    /// 调整颜色的饱和度
    /// - Parameter amount: 调整量（正值增加，负值减少）
    /// - Returns: 调整后的颜色
    func saturated(by amount: CGFloat) -> Color {
        var hue: CGFloat = 0
        var saturation: CGFloat = 0
        var brightness: CGFloat = 0
        var alpha: CGFloat = 0
        
        UIColor(self).getHue(&hue, saturation: &saturation, brightness: &brightness, alpha: &alpha)
        
        return Color(
            hue: Double(hue),
            saturation: Double(min(max(saturation + amount, 0), 1)),
            brightness: Double(brightness),
            opacity: Double(alpha)
        )
    }
}

// MARK: - UIColor 扩展（可选，用于 UIKit 兼容）
#if canImport(UIKit)
import UIKit

extension UIColor {
    /// 通过十六进制字符串初始化 UIColor
    /// - Parameter hex: 十六进制颜色字符串（例如 "FFFFFF"）
    convenience init(hex: String) {
        let color = Color(hex: hex)
        self.init(color)
    }
    
    /// 调整颜色亮度
    /// - Parameter percentage: 调整的百分比
    /// - Returns: 调整后的 UIColor
    func adjust(by percentage: CGFloat = 30.0) -> UIColor? {
        var red: CGFloat = 0, green: CGFloat = 0, blue: CGFloat = 0, alpha: CGFloat = 0
        if self.getRed(&red, green: &green, blue: &blue, alpha: &alpha) {
            return UIColor(
                red: min(red + percentage/100, 1.0),
                green: min(green + percentage/100, 1.0),
                blue: min(blue + percentage/100, 1.0),
                alpha: alpha
            )
        } else {
            return nil
        }
    }
}
#endif
