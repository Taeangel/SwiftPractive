//
//  RoundedShape.swift
//  SwiftUIFirebasePractice
//
//  Created by song on 2023/01/26.
//

import SwiftUI

struct RoundedShape: Shape {
  var corners: UIRectCorner
  
  func path(in rect: CGRect) -> Path {
    let path = UIBezierPath(roundedRect: rect,byRoundingCorners: corners, cornerRadii: CGSize(width: 80, height: 80))
    
    return Path(path.cgPath)
  }
  
}

