# Nautilus
### [Maelstrom Distrubuted challenges](https://fly.io/dist-sys/) solved in Swift.

inspired by https://github.com/jonhoo/rustengan

The solutions are built on a custom, declarative distributed systems framework, allowing for really simple code:

```swift
import Nautilus

@main
struct Echo: Node {
    var rules: RuleSet {
        Catch("echo") { message in
            message.reply(kind: "echo_ok", echo: message.body.echo)
        }
        // ...
    }
}
```

The code takes advantage of many Swift features and uses only structs and protocols; no classes or inheritance. The only exception is Foundation JSON decoding and encoding, but given the simple messages it should be relatively easy to implement something custom in the future.

The plan is to evaluate messages asynchronously using an async stream in order to prevent slower to generate responses from blocking the entire program.

If you also want to do the challenges but are not interested in implementing the framework from scratch you can import this as a Swift package and use it for your own solutions.

Tested using the latest Swift 5.8 pre-release on macOS 13, should work on Linux as well.

### Challenges solved so far:
- [x] 0a - Custom distributed framework
- [ ] 0b - Async
- [ ] 0c - Custom message declaration
- [x] 1 - Echo
- [x] 2 - Unique ID Generation
- [ ] 3 - Broadcast
- [ ] 4 - Grow only counter
- [ ] 5 - Kafka style log
- [ ] 6 - Totally available
