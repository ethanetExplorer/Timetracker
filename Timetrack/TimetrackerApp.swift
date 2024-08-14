//
//  StopwatchApp.swift
//  Stopwatch
//
//  Created by Ethan Lim on 13/6/24.
//

import SwiftUI

@main
struct StopwatchApp: App {
    @StateObject private var settings = Settings(fontChoice: .sansSerif, largerFont: .runningTotal, showSecondaryText: true, showMillisecondsAfterHour: false, expandLapsOnLap: true, resetToOneStopwatch: false, alwaysShowResetButton: false)
	@StateObject private var stopwatches = StopwatchViewModel()
//	@StateObject private var timers = TimerModel()
	@StateObject private var timerSet = TimerSet()
	@Environment(\.scenePhase) var scenePhase

	
//	@AppStorage("screen") var screenNumber: Int = 1 
	
	var body: some Scene {
		WindowGroup {
			TabView {
				Tab("Stopwatch", systemImage: "stopwatch") {
					StopwatchesMainView()
						.environmentObject(stopwatches)
						.environmentObject(settings)
						.onReceive(NotificationCenter.default.publisher(for: UIApplication.willTerminateNotification)) { _ in
							stopwatches.saveAllStopwatches()
						}
						.onReceive(NotificationCenter.default.publisher(for: UIApplication.didEnterBackgroundNotification)) { _ in
							stopwatches.saveAllStopwatches()
						}
				}
				
				Tab("Timer", systemImage: "timer") {
					TimersView(timerSet: timerSet)
						.environmentObject(settings)
						.onAppear {
							timerSet.loadTimers()
						}
						.onDisappear {
							timerSet.saveTimers()
						}
					
				}
				
				Tab("Settings", systemImage: "gear") {
					SettingsView()
						.environmentObject(settings)
				}
			}
		}
		
		.onChange(of: scenePhase) { newPhase in
			if newPhase == .background {
				let currentTimestamp = Date().timeIntervalSince1970
				print("Saving lastCloseDate: \(currentTimestamp)")
				UserDefaults.standard.set(currentTimestamp, forKey: "lastCloseDate")
				timerSet.saveTimers()
			}
		}
	}
}
