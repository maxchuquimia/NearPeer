//
//  NearPeerState.swift
//  NearPeer
//
//  Created by Max Chuquimia on 22/5/2022.
//

import Foundation

public extension NearPeer {

    enum State: Equatable {

        /// Nothing is happening.
        case idle

        /// NearPeer is searching for nearby devices in the `broadcastingNewSession` or
        /// `hostingSession` states.
        case searchingForActiveSessions

        /// NearPeer is broadcasting itself as a new session to other nearby devices in
        /// the `searchingForActiveSessions` state.
        case broadcastingNewSession

        /// NearPeer has at least one other connected device and is continuing to broadcast
        /// itself for future nearby devices in the `searchingForActiveSessions` state.
        case hostingSession

        /// NearPeer is connected to a nearby device in the `hostingSession` state.
        case connectedToExistingSession

    }

}
