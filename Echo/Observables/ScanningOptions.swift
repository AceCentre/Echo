//
//  ScanningOptions.swift
//  Echo
//
//  Created by Gavin Henderson on 05/10/2023.
//

import Foundation
import SwiftUI
import SharedEcho

class ScanningOptions: ObservableObject {    
    @AppStorage(StorageKeys.scanning) var scanning = true
    @AppStorage(StorageKeys.scanWaitTime) var scanWaitTime: Double = 2
    @AppStorage(StorageKeys.scanLoops) var scanLoops: Int = 3
    @AppStorage(StorageKeys.scanOnLaunch) var scanOnAppLaunch = true
    @AppStorage(StorageKeys.scanAfterSelection) var scanAfterSelection = true
    
    func getAnalyticData() -> [String: Any] {
        return [
            "scanning": scanning,
            "scanWaitTime": scanWaitTime,
            "scanLoops": scanLoops,
            "scanOnLaunch": scanOnAppLaunch,
            "scanAfterSelection": scanAfterSelection
        ]
    }
}
