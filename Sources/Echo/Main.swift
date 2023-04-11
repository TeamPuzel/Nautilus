
import Nautilus

@main
struct Echo: Node {
    
    static var id: String!
    static var nodes: [String]!
    
    var rules: RuleSet {
        Catch("echo") { message in
            message.reply()
        }
        Catch("echo") { message in
            message.reply()
        }
    }
}
