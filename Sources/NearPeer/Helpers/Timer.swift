//
//  Timer.swift
//  
//
//  Created by Max Chuquimia on 22/5/2022.
//

import Foundation

extension Timer {

    static func dispatchAfter(_ interval: TimeInterval, tolerance: TimeInterval = 1, handler: @escaping () -> Void) -> Timer {
        let timer = Timer.scheduledTimer(withTimeInterval: interval, repeats: false, block: { _ in handler() })
        timer.tolerance = tolerance
        return timer
    }

}
