
public protocol Node {
    static var id: String! { get set }
    static var nodes: [String]! { get set }
    @RuleSetBuilder var rules: RuleSet { get }
}

internal var rules: [String: Catch.Callback] = [:]

public extension Node {
    static func main() async {
        // First the node has to acknowledge ok status
        while true {
            let message = Message.poll()
            guard message.body.kind == "init" else { continue }
            #warning("TODO! Implement setup")
        }
        
        // Event loop
        while true {
            let message = Message.poll()
            if let callback = Nautilus.rules[message.body.kind] {
                callback(message).dispatch()
            } else {
                fatalError("Unknown message: \(message)")
            }
        }
    }
}

// MARK: - DSL

public struct RuleSet {
    var rules: [String: Catch.Callback] = [:]
}
        
public struct Catch {
    
    // TODO: Async!!
    // This system could work based on a stream/channel,
    // queueing messages but computing replies without waiting.
    // That's the only kind of concurrency possible
    // because only one thread can read or write to a file.
    //
    // But there is a downside, state will need to be synchronised.
    public typealias Callback = (_ message: Message) -> Message
    
    let kind: String
    let callback: Callback
    
    public init(_ kind: String, callback: @escaping Callback) {
        self.kind = kind; self.callback = callback
    }
}

@resultBuilder
public struct RuleSetBuilder {
    public static func buildBlock(_ components: Catch...) -> RuleSet {
        var ruleSet = RuleSet()
        for component in components {
            guard !rules.contains(where: { $0.key == component.kind }) else {
                fatalError("Duplicate rules not allowed: \(component.kind)")
            }
            ruleSet.rules[component.kind] = component.callback
        }
        return ruleSet
    }
}

