
import Nautilus

@main
struct Broadcast: Node {
    
    @State("messages") var messages: [Int] = []
    @State("neighbors") var neighbors: [String] = []
    
    var rules: RuleSet {
        Catch("broadcast") { message in
            self.messages.append(message.body.message!)
            for node in Global.nodes.filter({ $0 != Global.id }) {
                Task {
                    await Message(
                        destination: node,
                        kind: "re_broadcast",
                        message: message.body.message!
                    )
                        .dispatch()
                }
            }
            return message.reply(kind: "broadcast_ok")
        }
        Catch("re_broadcast") { message in
            self.messages.append(message.body.message!)
            return nil
        }
        Catch("read") { message in
            message.reply(kind: "read_ok", messages: messages)
        }
        Catch("topology") { message in
            self.neighbors.append(contentsOf: message.body.topology![Global.id]!)
            return message.reply(kind: "topology_ok")
        }
    }
}
