//
//  TImerItemView.swift
//  Stopwatch
//
//  Created by Ethan Lim on 16/8/24.
//

import SwiftUI

struct TimerItemView: View {
	
	@EnvironmentObject var settings: Settings
	@ObservedObject var timer: TimerItem
	@Binding var showDeleteAlert: Bool
	
	var body: some View {
		HStack {
			VStack(alignment:.leading) {
				Text(timer.label)
					.multilineTextAlignment(.leading)
					.foregroundStyle(.gray)
				Text(formatTime(input: timer.time))
					.font(.title)
					.monospaced(settings.fontChoice == .monospace)
				//					.onReceive(timer.$time) { _ in
				//						// Force a UI update when `time` changes
				//						self.objectWillChange.send()
				//					}
			}
			Spacer()
			if timer.status == .notStarted || timer.status == .paused {
				Button {
					timer.start()
				} label: {
					actionButtonLabel(image: "play.fill", color: .green)
				}
			} else if timer.status == .finished {
				Button {
					showDeleteAlert = true
				} label: {
					actionButtonLabel(image: "flag.pattern.checkered", color: .pink)
				}
			} else {
				Button {
					timer.stop()
				} label: {
					actionButtonLabel(image: "stop.fill", color: .red)
				}
			}
			Button {
				timer.reset()
			} label: {
				actionButtonLabel(image: "arrow.circlepath", color: .yellow)
			}
			
		}
		.padding(.horizontal)
	}
	
	
	func actionButtonLabel(image: String, color: Color) -> some View {
		Image(systemName: image)
			.font(.title)
			.foregroundStyle(color)
			.padding(10)
			.background(color.opacity(0.2))
			.clipShape(Circle())
	}
	
	func formatTime(input: Double) -> String {
		let seconds = Int(input) % 60
		let minutes = (Int(input) / 60) % 60
		let hours = Int(input) / 3600
		let milliseconds = Int((input.truncatingRemainder(dividingBy: 1)) * 100)
		
		if hours > 0 {
			return settings.showMillisecondsAfterHour ? String(format: "%02d:%02d:%02d:%02d", hours, minutes, seconds, milliseconds) : String(format: "%02d:%02d:%02d", hours, minutes, seconds)
		} else if minutes > 0 {
			return String(format: "%02d:%02d:%02d", minutes, seconds, milliseconds)
		} else {
			return String(format: "00:%02d:%02d", seconds, milliseconds)
		}
	}
}
