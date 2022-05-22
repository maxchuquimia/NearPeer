//
//  NearPeerDelegate.swift
//  NearPeer
//
//  Created by Max Chuquimia on 1/5/2022.
//

import Foundation

public protocol NearPeerDelegate: AnyObject {
    /// Called when the list of nearby devices changes
    func connectedPeersDidChange(to peers: Set<NearPeer.ID>)

    /// Called when a message is recieved from nearby devices
    func didReceiveMessageFromPeer(message: Data, peer: NearPeer.ID)

    /// Called when an error occurs (typically from the `MultipeerConnectivity` framework)
    func handle(error: Error)

    /// Called when the state changes
    func stateDidChange(from oldValue: NearPeer.State, to newState: NearPeer.State)
}

public extension NearPeerDelegate {

    func stateDidChange(from oldValue: NearPeer.State, to newState: NearPeer.State) {}

}
