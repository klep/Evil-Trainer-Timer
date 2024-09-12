//
//  DummyView.swift
//  Evil Trainer Timer
//
//  Created by Scott J. Kleper on 9/12/24.
//

import SwiftUI

struct DummyView: View {
  private let label: String
  private let image: String
  
  init(_ label: String, _ image: String) {
    self.label = label
    self.image = image
  }
  
  var body: some View {
    Text("hi")
      .tabItem {
        Label(label, systemImage: image)
      }
  }
}
