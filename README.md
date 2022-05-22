# NearPeer

A lightweight "just works" wrapper around the `MultipeerConnectivity` framework.
Great for POCs and small projects!

## How it works

`NearPeer` oscilates between "searching" and "broadcasting" states in order to try to connect to `NearPeer` instances running on other devices.
This could be instant, or take some time (depending on the state of other devices also trying to start a connection). Set `NearPeerConstants.advertisingDuration` and `NearPeerConstants.searchDuration` to configure this behaviour.

## Usage

```swift
import NearPeer

final class YourAppService: NearPeerDelegate {

    private let nearPeer = NearPeer(serviceType: "yourapp")
    
    init() {
        nearPeer.delegate = self
        nearPeer.joinPeers()
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
    
}
```

## Support
- No unit tests at this time
- Manually tested with two devices for quite some time
- Briefly tested with three devices and it seemed to work
