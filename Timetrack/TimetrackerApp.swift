//
//  StopwatchApp.swift
//  Stopwatch
//
//  Created by Ethan Lim on 13/6/24.
//

import SwiftUI
import SwiftData

@main
struct StopwatchApp: App {
	
	@StateObject private var settings = Settings(fontChoice: .sansSerif, largerFont: .runningTotal, showSecondaryText: true, showMillisecondsAfterHour: false, expandLapsOnLap: true, resetToOneStopwatch: false, alwaysShowResetButton: false)
	
	
	var body: some Scene {
		WindowGroup {
			TabView {
				Tab("Stopwatch", systemImage: "stopwatch") {
					StopwatchMainView()
						.environmentObject(settings)
						.modelContainer(for: [Stopwatch.self, StopwatchSet.self])
				}
				
				Tab("Timer", systemImage: "timer") {
					TimersView()
						.environmentObject(settings)
						.modelContainer(for: [TimerItem.self, TimerSet.self])
				}
				
				Tab("Settings", systemImage: "gear") {
					SettingsView()
						.environmentObject(settings)
				}
			}
		}
	}
}
