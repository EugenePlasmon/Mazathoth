//
//  UIColor+Extensions.swift
//  Mazathoth
//
//  Created by Evgeny Kireev on 12/04/2019.
//  Copyright © 2019 plasmon. All rights reserved.
//

import UIKit

public extension UIColor {
    
    // MARK: - Brand Colors
    
    static let brandLightBlue = UIColor(red: 41.0 / 255.0, green: 120.0 / 255.0, blue: 240.0 / 255.0, alpha: 1.0)
    static let brandBlue = UIColor(red: 41.0 / 255.0, green: 74.0 / 255.0, blue: 240.0 / 255.0, alpha: 1.0)

    /// Создает объект UIColor с цветом закодированным в hex строке
    ///
    /// - Parameter hexString: строка с цветом в hex формате (#EC174F)
    /// - Returns: Объект UIColor, либо nil если переданную строку не удалось распарсить
    static func color(hexString: String) -> UIColor? {
        var cString = hexString.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
        if cString.hasPrefix("#") {
            cString.remove(at: cString.startIndex)
        }
        if cString.count != 6 {
            return nil
        }
        let allowedChars = CharacterSet(charactersIn: "0123456789ABCDEF")
        guard cString.rangeOfCharacter(from: allowedChars.inverted) == nil else {
            return nil
        }
        
        var rgbValue: UInt32 = 0
        Scanner(string: cString).scanHexInt32(&rgbValue)
        return UIColor(
            red: CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0,
            green: CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0,
            blue: CGFloat(rgbValue & 0x0000FF) / 255.0,
            alpha: CGFloat(1.0)
        )
    }
    
    /// Создает объект UIColor из переданных параметров согласно цветовой схеме rgb
    ///
    /// - Parameters:
    ///   - red: Число от `0` до `255`, интенсивность красного цвета
    ///   - green: Число от `0` до `255`, интенсивность зеленого цвета
    ///   - blue: Число от `0` до `255`, интенсивность синего цвета
    /// - Returns: Объект UIColor
    static func rgb(_ red: CGFloat, _ green: CGFloat, _ blue: CGFloat) -> UIColor {
        return rgba(red, green, blue, 1.0)
    }
    
    /// Создает объект UIColor из переданных параметров согласно цветовой схеме rgb. Содержит параметр `a`, отвечающий за непрозрачность
    ///
    /// - Parameters:
    ///   - red: Число от `0` до `255`, интенсивность красного цвета
    ///   - green: Число от `0` до `255`, интенсивность зеленого цвета
    ///   - blue: Число от `0` до `255`, интенсивность синего цвета
    ///   - alpha: Число от `0` до `1`, непрозрачность. Значение `0` соответствует полностью прозрачному цвету, `1` - полностью непрозрачному.
    /// - Returns: Объект UIColor
    static func rgba(_ red: CGFloat, _ green: CGFloat, _ blue: CGFloat, _ alpha: CGFloat) -> UIColor {
        return UIColor(red: red/255.0, green: green/255.0, blue: blue/255.0, alpha: alpha)
    }
}
