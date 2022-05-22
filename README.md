# NearPeer

A lightweight "just works" wrapper around the `MultipeerConnectivity` framework.
Great for POCs and small projects!

## How it works

`NearPeer` oscilates between "searching" and "broadcasting" states in order to try to connect to `NearPeer` instances running on other devices.
This could be instant, or take some time (depending on the state of other devices also trying to start a connection). Set `NearPeerConstants.advertisingDuration` and `NearPeerConstants.searchDuration` to configure this behaviour.

## Usage

1. Create a `NearPeer` instance with a unique-to-your-app `serviceType`
2. Set it's delegate
3. Call `joinPeers()` to start looking for nearby instances
4. Use `broadcast(data:)` to send `Data` to all connected peers (try [this](https://github.com/apple/swift-protobuf) for encoding messages!)
5. Use `didReceiveMessageFromPeer(message:peer:)` to listen for messages from all connected peers
6. Call `stop()` to end the session

```swift
import NearPeer

final class YourAppService: NearPeerDelegate {

    private let nearPeer = NearPeer(serviceType: "yourapp")

    init() {
        nearPeer.delegate = self
        nearPeer.joinPeers()
    }

    func broadcast(data: Data) {
        nearPeer.broadcast(data: data)
    }

    deinit {
        nearPeer.stop()
    }

}

extension YourAppService: NearPeerDelegate {

    func connectedPeersDidChange(to peers: Set<NearPeer.ID>) {
        // Someone joined or left the network
    }

    func didReceiveMessageFromPeer(message: Data, peer: NearPeer.ID) {
        // Someone on the network broadcast the message `message`
    }

    func handle(error: Error) {
        // An error occurred
    }

    func stateDidChange(from oldValue: NearPeer.State, to newState: NearPeer.State) {
        // The state of the instance changed
    }   

}
```

For more advanced control, see `NearPeerConstants.swift`.

## Support
- Built for use in [On Air](https://github.com/maxchuquimia/OnAir)
- No unit tests at this time
- Thoroughly manually tested with two devices
- Briefly tested with three devices and it seemed to work
