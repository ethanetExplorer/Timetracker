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
	@StateObject private var timers = TimersViewModel()
	@AppStorage("timerSet") private var savedTimerSetData: Data?
	@StateObject private var timerSet = TimerSet.load()
	
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
					TimersView()
						.environmentObject(settings)
//						.environmentObject(timers)
//						.onAppear {
//							timers.loadTimers()
//						}
//						.onReceive(NotificationCenter.default.publisher(for: UIApplication.didEnterBackgroundNotification)) { _ in
//							timers.saveTimers()
//						}
					
						
						.environmentObject(timerSet)
						.onAppear {
							timerSet.save()
						}
						.onReceive(NotificationCenter.default.publisher(for: UIApplication.didEnterBackgroundNotification)) { _ in
							timerSet.save()
						}
						.onReceive(NotificationCenter.default.publisher(for: UIApplication.willTerminateNotification)) { _ in
							timerSet.save()
						}
				}
				
				Tab("Settings", systemImage: "gear") {
					SettingsView()
						.environmentObject(settings)
				}
			}
		}
	}
}
