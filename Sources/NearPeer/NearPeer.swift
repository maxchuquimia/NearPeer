//
//  NearPeer.swift
//  NearPeer
//
//  Created by Max Chuquimia on 1/5/2022.
//

import Foundation
import MultipeerConnectivity

public final class NearPeer: NSObject {

    public weak var delegate: NearPeerDelegate?
    public let localID: ID
    public private(set) var state: State = .idle {
        didSet { stateDidChange(from: oldValue) }
    }

    private var advertiser: MCNearbyServiceAdvertiser?
    private var browser: MCNearbyServiceBrowser?
    private let session: MCSession
    private let peer: MCPeerID
    private let serviceType: String

    private let advertiserHandler: ServiceAdvertiserHandler
    private let browserHandler: ServiceBrowserHandler
    private let sessionHandler: SessionHandler

    private var nextStateChangeTimer: Timer?
    private var refreshDebouncer: Timer?

    /// Creates a NearPeer instance.
    /// - Parameters:
    ///   - serviceType: A short, unique-for-your-app string that identifies the local network.
    ///   - id: A short identifier for the current device
    required init(serviceType: String, id: NearPeer.ID = NearPeer.ID()) {
        self.localID = id
        self.serviceType = serviceType
        peer = MCPeerID(displayName: id.id)
        advertiser = MCNearbyServiceAdvertiser(peer: peer, discoveryInfo: nil, serviceType: serviceType)
        browser = MCNearbyServiceBrowser(peer: peer, serviceType: serviceType)
        session = MCSession(peer: peer, securityIdentity: nil, encryptionPreference: .none)

        advertiserHandler = ServiceAdvertiserHandler(session: session)
        browserHandler = ServiceBrowserHandler(session: session)
        sessionHandler = SessionHandler()

        super.init()
        setup()
    }

    deinit {
        stop()
    }

}

public extension NearPeer {

    func joinPeers() {
        guard state == .idle else { return }
        searchForActiveSessions()
    }

    func stop() {
        nextStateChangeTimer?.invalidate()
        session.disconnect()
        advertiser?.stopAdvertisingPeer()
        browser?.stopBrowsingForPeers()
        state = .idle
    }

    func broadcast(data: Data) {
        guard !session.connectedPeers.isEmpty else { return }
        do {
            try session.send(data, toPeers: session.connectedPeers, with: .reliable)
        } catch {
            handle(error: error)
        }
    }

}

private extension NearPeer {

    func setup() {
        advertiser?.delegate = advertiserHandler
        browser?.delegate = browserHandler
        session.delegate = sessionHandler

        advertiserHandler.errorHandler = { [weak self] in self?.handle(error: $0) }
        browserHandler.errorHandler = { [weak self] in self?.handle(error: $0) }
        browserHandler.lostPeerHandler = { [weak self] in self?.refreshIfNeeded() }
        sessionHandler.peerUpdateHandler = { [weak self] in self?.handlePeerListChange(connectedPeers: $0) }
        sessionHandler.receivedDataHandler = { [weak self] in self?.handle(data: $0, from: $1) }
    }

    func _stopAdvertising() {
        guard advertiser != nil else { return }
        advertiser?.delegate = nil
        advertiser?.stopAdvertisingPeer()
        advertiser = nil
    }

    func _startAdvertising() {
        _stopAdvertising()
        advertiser = MCNearbyServiceAdvertiser(peer: peer, discoveryInfo: nil, serviceType: serviceType)
        advertiser?.delegate = advertiserHandler
        advertiser?.startAdvertisingPeer()
    }

    func _stopBrowsing() {
        guard browser != nil else { return }
        browser?.delegate = nil
        browser?.stopBrowsingForPeers()
        browser = nil
    }

    func _startBrowsing() {
        _stopBrowsing()
        browser = MCNearbyServiceBrowser(peer: peer, serviceType: serviceType)
        browser?.delegate = browserHandler
        browser?.startBrowsingForPeers()
    }

    func searchForActiveSessions() {
        _stopAdvertising()
        DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(1)) { [self] in
            state = .searchingForActiveSessions

            browserHandler.willInvitePeerToSessionHandler = { [weak self] in
                self?.nextStateChangeTimer?.invalidate()
                self?.state = .connectedToExistingSession
            }

            _startBrowsing()

            nextStateChangeTimer?.invalidate()
            nextStateChangeTimer = .scheduledTimer(withTimeInterval: NearPeerConstants.searchDuration(), repeats: false, block: { [weak self] _ in
                // Failed to find an existing session in time, so create a new session
                self?.broadcastNewSession()
            })
            nextStateChangeTimer?.tolerance = 1.0
        }
    }

    func broadcastNewSession() {
        _stopBrowsing()
        DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(1)) { [self] in
            state = .broadcastingNewSession

            advertiserHandler.willAcceptPeerInvitationHandler = { [weak self] in
                self?.nextStateChangeTimer?.invalidate()
                self?.state = .hostingSession
            }

            _startAdvertising()

            nextStateChangeTimer?.invalidate()
            nextStateChangeTimer = .scheduledTimer(withTimeInterval: NearPeerConstants.advertisingDuration(), repeats: false, block: { [weak self] _ in
                // Failed to find an existing session in time, so create a new session
                self?.searchForActiveSessions()
            })
            nextStateChangeTimer?.tolerance = 1.0
        }
    }

    func refreshIfNeeded() {
        refreshDebouncer?.invalidate()
        guard session.connectedPeers.isEmpty else { return NearPeerConstants.logger("No need to refresh, found \(session.connectedPeers)") }
        NearPeerConstants.logger("Scheduling refresh")
        // If session.connectedPeers.isEmpty is empty, schedule a refresh
        refreshDebouncer = .scheduledTimer(withTimeInterval: 3.0, repeats: false, block: { [weak self] _ in
            self?.doRefresh()
        })
        refreshDebouncer?.tolerance = 1.0
    }

    func stateDidChange(from oldValue: State) {
        NearPeerConstants.logger("State changed: \(oldValue) -> \(state)")
    }

    func handle(error: Error) {
        NearPeerConstants.logger("Error: \(error)")
        switch error {
        case MCError.timedOut, MCError.notConnected:
            refreshIfNeeded()
        default:
            delegate?.handle(error: error)
        }
    }

    func doRefresh() {
        switch state {
        case .searchingForActiveSessions, .connectedToExistingSession:
            broadcastNewSession()
        case .broadcastingNewSession, .hostingSession:
            searchForActiveSessions()
        case .idle:
            stop()
            joinPeers()
        }
    }

    func handlePeerListChange(connectedPeers: [MCPeerID]) {
        refreshIfNeeded()
        let peers = Set(connectedPeers.map(ID.init))
        delegate?.connectedPeersDidChange(to: peers)
    }

    func handle(data: Data, from peer: MCPeerID) {
        delegate?.didReceiveMessageFromPeer(message: data, peer: .init(peerID: peer))
    }

}