//
//  ContentView.swift
//  Evil Trainer Timer
//
//  Created by Scott J. Kleper on 8/26/24.
//

import SwiftUI

struct ContentView: View {
  let timer = Timer.publish(every: 0.01, on: .main, in: .common).autoconnect()
  @State private var duration: TimeInterval = 0.0
  @State private var isRunning = false
  @State private var selectedTab: Int = 2
  @State private var mode: Mode = .evil
  @State private var feedback = " "
  @State private var lastFeedbackDuration = 0.0
  
  var body: some View {
    GeometryReader { geometry in
      TabView(selection: $selectedTab) {
        DummyView("World Clock", "globe")
        DummyView("Alarms", "alarm")
        mainView(geometry)
          .tag(2)
          .frame(maxWidth: .infinity, maxHeight: .infinity)
          .background(.black)
          .ignoresSafeArea()
          .tabItem {
            Label("Stopwatch", systemImage: "stopwatch")
          }
        settingsView
          .tag(3)
          .frame(maxWidth: .infinity, maxHeight: .infinity)
          .background(.black)
          .ignoresSafeArea()
          .tabItem {
            Label("Timers", systemImage: "timer")
          }
      }
      .tint(.orange)
    }
    .onAppear {
      UITabBar.appearance().unselectedItemTintColor = UIColor(red: 117.0/255.0, green: 117.0/255.0, blue: 117.0/255.0, alpha: 1.0)
    }
    .onReceive(timer) { input in
      if isRunning {
        duration += 0.01 * mode.multipler
        if duration - lastFeedbackDuration > 5.0 {
          withAnimation {
            feedback = mode.feedback
          }
          DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
            lastFeedbackDuration = duration
            withAnimation {
              feedback = " "
            }
          }
          lastFeedbackDuration = duration
        }
      }
    }
  }

  private enum Mode: String {
    case normal
    case evil
    case marissa2
    
    var multipler: Double {
      switch self {
      case .normal: return 1.0
      case .evil: return 0.8571428571
      case .marissa2: return 1.0
      }
    }
    
    var feedback: String {
      switch self {
      case .normal: return " "
      case .evil: return " "
      case .marissa2: return [
        "You got this!",
        "Almost there!",
        "Pain is something something leaving something",
        "Look at those muscles!",
        "Rude!"
      ].randomElement()!
      }
    }
  }
  
  @ViewBuilder
  private var settingsView: some View {
    VStack {
      Picker("Mode", selection: $mode) {
        Text("Normal").tag(Mode.normal)
        Text("Evil").tag(Mode.evil)
        Text("Marissa 2").tag(Mode.marissa2)
      }
      .pickerStyle(.segmented)
      .background(Color.orange)
      .cornerRadius(8)
      .foregroundColor(.black)
      .padding(8)
    }
  }
  
  private var tensOfMinutes: Int {
    let duration = duration.truncatingRemainder(dividingBy: 3600)
    return Int(duration / 600)
  }

  private var minutes: Int {
    let duration = duration.truncatingRemainder(dividingBy: 3600)
    return Int(duration / 60) % 10
  }
  
  private var tensOfSeconds: Int {
    let duration = duration.truncatingRemainder(dividingBy: 60)
    return Int(duration / 10)
  }
  
  private var seconds: Int {
    let duration = duration.truncatingRemainder(dividingBy: 60)
    return Int(duration) % 10
  }
    
  private var tensOfMilliseconds: Int {
    let duration = duration.truncatingRemainder(dividingBy: 1)
    return Int(duration * 100) / 10
  }
  
  private var milliseconds: Int {
    let duration = duration.truncatingRemainder(dividingBy: 1)
    return Int(duration * 100) % 10
  }

  private func widthForSeparator(_ width: CGFloat) -> CGFloat {
    width / 25
  }
  
  private func widthForDigit(_ width: CGFloat) -> CGFloat {
    return (width - widthForSeparator(width) * 1.5) / 6
  }
  
  @ViewBuilder
  private func timeStack(withAvailableWidth availableWidth: CGFloat, colonPadding: CGFloat = 20) -> some View {
    let width = widthForDigit(availableWidth)
    let widthForSeparator = widthForSeparator(availableWidth)
    
    HStack(alignment: .center, spacing: 0) {
      Text(String(format: "%01d", tensOfMinutes))
        .frame(width: width)
      Text(String(format: "%01d", minutes))
        .frame(width: width)
      Text(":")
        .multilineTextAlignment(.center)
        .frame(width: widthForSeparator, alignment: .center)
        .padding(.bottom, colonPadding)
      Text(String(format: "%01d", tensOfSeconds))
        .frame(width: width)
      Text(String(format: "%01d", seconds))
        .frame(width: width)
      Text(".")
        .multilineTextAlignment(.center)
        .frame(width: widthForSeparator, alignment: .center)
      Text(String(format: "%01d", tensOfMilliseconds))
        .frame(width: width)
      Text(String(format: "%01d", milliseconds))
        .frame(width: width)
    }
    .frame(maxWidth: .infinity)
    .foregroundStyle(.white)
  }
  
  @ViewBuilder
  private func mainView(_ geometry: GeometryProxy) -> some View {
    VStack {
      Spacer(minLength: 100)
      timeStack(withAvailableWidth: geometry.size.width)
        .font(.system(size: widthForDigit(geometry.size.width) * 1.6, weight: .thin))
        .foregroundStyle(.white)
        .frame(maxWidth: .infinity)
      
      Text(feedback)
        .font(.system(size: 24))
        .foregroundStyle(.orange)
        .id(feedback) // hack so animation triggers
        .transition(.opacity)
        .lineLimit(1)
        .minimumScaleFactor(0.2)
        .padding(.horizontal, 12)
        .frame(height: 50)
      
      HStack {
        Button {
          duration = 0.0
        } label: {
          Circle()
            .frame(width: 100, height: 100)
            .foregroundStyle(.white.opacity(0.2))
            .overlay {
              Text("Reset")
                .font(.system(size: 24, weight: .medium))
                .foregroundStyle(.white)
            }
        }
        Spacer()
        Circle()
          .frame(width: 10)
          .foregroundStyle(.white)
          .padding(.trailing, 2)
        Circle()
          .frame(width: 10)
          .foregroundStyle(.gray)
        Spacer()
        Button {
          isRunning.toggle()
        } label: {
          Circle()
            .frame(width: 100, height: 100)
            .foregroundStyle(isRunning ? .red.opacity(0.3) : .green.opacity(0.3))
            .overlay {
              Text(isRunning ? "Stop" : "Start")
                .font(.system(size: 24, weight: .medium))
                .foregroundStyle(isRunning ? .red : .green)
            }
        }
      }
      .padding(.horizontal, 12)
      .padding(.bottom, 12)
      
      Group {
        Rectangle()
          .frame(maxWidth: .infinity, maxHeight: 1)
          .foregroundStyle(.gray.opacity(0.5))
        HStack {
          Text("Lap 1")
            .font(.system(size: 24, weight: .medium))
            .foregroundStyle(.white)
          Spacer()
          timeStack(withAvailableWidth: geometry.size.width * 0.25, colonPadding: 5)
            .frame(maxWidth: geometry.size.width * 0.25)
            .font(.system(size: widthForDigit(geometry.size.width * 0.25) * 1.6, weight: .medium))
            .padding(.trailing, 8)
        }
        .frame(maxWidth: .infinity)
        
        Rectangle()
          .frame(maxWidth: .infinity, maxHeight: 1)
          .foregroundStyle(.gray.opacity(0.5))
      }
      .padding(.horizontal, 4)
      
      Spacer(minLength: 100)
    }
  }
}

#Preview {
  ContentView()
}
