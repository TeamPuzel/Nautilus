# Nautilus
### [Maelstrom Distrubuted challenges](https://fly.io/dist-sys/) solved in Swift.

The solutions are built on a custom, declarative distributed systems framework, allowing for really simple code:

```swift
import Nautilus

@main
struct Echo: Node {
    var rules: RuleSet {
        Catch("echo") { message in
            message.reply(kind: "echo_ok", echo: message.body.echo)
        }
    }
}
```

If you also want to do the challenges but are not interested in implementing the framework from scratch you can import this as a Swift package and use it for your own solutions.

### Challenges solved so far:
- [x] 0 - Custom distributed framework
- [x] 1 - Echo
- [ ] 2 - Unique ID Generation
- [ ] 3 - Broadcast
- [ ] 4 - Grow only counter
- [ ] 5 - Kafka style log
- [ ] 6 - Totally available
