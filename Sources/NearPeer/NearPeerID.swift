//
//  NearPeerID.swift
//  NearPeer
//
//  Created by Max Chuquimia on 1/5/2022.
//

import Foundation
import MultipeerConnectivity

public extension NearPeer {

    struct ID: Hashable {

        public let id: String

        public init() {
            let _id = UUID()
                .uuidString
                .replacingOccurrences(of: "-", with: "")
            id = String(_id[_id.startIndex..<_id.index(_id.startIndex, offsetBy: 15)])
        }

        public init(id: String) {
            self.id = id
        }

        public init(peerID: MCPeerID) {
            self.id = peerID.displayName
        }

    }

}
