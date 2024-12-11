//
//  TimersMainView.swift
//  Stopwatch
//
//  Created by Ethan Lim on 2024-12-11.
//

import SwiftUI
import SwiftData

struct TimersMainView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var timers: [TimerItem]
    @State private var timer: Timer?
    @State private var elapsedTime: TimeInterval = 0
    @State private var displayTime: String = "00:00:00"
    
    var body: some View {
        VStack(spacing: 20) {
            Text(displayTime)
                .font(.largeTitle)
                .padding()
            
            HStack {
                Button(action: startTimer) {
                    Text("Start")
                        .padding()
                        .background(Color.green)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                }
                Button(action: stopTimer) {
                    Text("Stop")
                        .padding()
                        .background(Color.yellow)
                        .foregroundColor(.black)
                        .cornerRadius(8)
                }
                Button(action: resetTimer) {
                    Text("Reset")
                        .padding()
                        .background(Color.red)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                }
            }
        }
        .onAppear(perform: loadTimerState)
        .onDisappear(perform: saveTimerState)
    }
    
    private func startTimer() {
        guard timer == nil else { return }
        
        if let timer = timers.first, !timer.isRunning {
            timer.startTime = Date()
            timer.isRunning = true
            try? modelContext.save()
        } else if timers.isEmpty {
            let newTimer = TimerItem(startTime: Date(), elapsedTime: elapsedTime, isRunning: true)
            modelContext.insert(newTimer)
            try? modelContext.save()
        }
        
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
            updateElapsedTime()
        }
    }
    
    private func stopTimer() {
        timer?.invalidate()
        timer = nil
        
        if let timer = timers.first {
            timer.isRunning = false
            timer.elapsedTime = elapsedTime
            try? modelContext.save()
        }
    }
    
    private func resetTimer() {
        timer?.invalidate()
        timer = nil
        elapsedTime = 0
        displayTime = "00:00:00"
        
        if let timer = timers.first {
            modelContext.delete(timer)
            try? modelContext.save()
        }
    }
    
    private func updateElapsedTime() {
        if let timer = timers.first {
            elapsedTime = timer.elapsedTime + (timer.startTime?.timeIntervalSinceNow ?? 0) * -1
            displayTime = formatTime(elapsedTime)
        }
    }
    
    private func loadTimerState() {
        if let timer = timers.first {
            elapsedTime = timer.elapsedTime
            if timer.isRunning, let startTime = timer.startTime {
                elapsedTime += Date().timeIntervalSince(startTime)
                startTimer()
            }
            displayTime = formatTime(elapsedTime)
        }
    }
    
    private func saveTimerState() {
        if let timer = timers.first {
            timer.elapsedTime = elapsedTime
            try? modelContext.save()
        }
    }
    
    private func formatTime(_ timeInterval: TimeInterval) -> String {
        let hours = Int(timeInterval) / 3600
        let minutes = (Int(timeInterval) % 3600) / 60
        let seconds = Int(timeInterval) % 60
        return String(format: "%02d:%02d:%02d", hours, minutes, seconds)
    }
}

#Preview {
    TimersMainView()
}
