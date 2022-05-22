//
//  NearPeerConstants.swift
//  NearPeer
//
//  Created by Max Chuquimia on 1/5/2022.
//

import Foundation

public enum NearPeerConstants {

    /// A base timeout for attempting to connect to devices
    public static var connectionTimeout: TimeInterval = 10.0

    /// The duration for which NearPeer should remain in the `broadcastingNewSession`
    /// state as it waits for nearby devices to connect.
    public static var advertisingDuration: () -> TimeInterval = {
        (connectionTimeout * 2) + TimeInterval(arc4random_uniform(UInt32(connectionTimeout)))
    }

    /// The duration for which NearPeer should remain in the `searchingForActiveSessions`
    /// state as it searches for nearby devices to connect to.
    /// Recommendation: keep this is shorter than `advertisingDuration`!
    public static var searchDuration: () -> TimeInterval = {
        connectionTimeout * 1.5
    }

    /// A logger to which debug messages should be written.
    public static var logger: (String) -> Void = { message in
        #if DEBUG
        print("[NearPeer]", message)
        #else
        _ = message
        #endif
    }

}
