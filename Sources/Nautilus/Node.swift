
/// Conformance to this protocol and marking an object with `@main`
/// will automatically set it up as a node, with a simple and declarative
/// interface for describing requests and their replies.
///
/// There can only be one node.
public protocol Node {
    @RuleSetBuilder var rules: RuleSet { get }
    @RuleSetBuilder var internalRules: RuleSet { get }
    init()
}

/// A namespace to contain shared node state instead of passing
/// around copies everywhere. Useful for performance reasons.
public enum State {
    /// Current node ID.
    public static var id: String!
    /// Contains all known nodes including itself.
    public static var nodes: [String] = []
    /// Contains all the rules describing node behavior.
    ///
    /// This dictionary is queried for a matching message `kind`
    /// and if successful will execute the corresponsing callback.
    internal static var rules: [String: Catch.Callback] = [:]
    internal static var node: Node!
}

public extension Node {
    static func main() async {
        State.node = Self()
        // First the rules need to be initialized
        State.rules.merge(
            State.node.rules.rules
        ) { _, _ in fatalError("Duplicate rules, reason undefined") }
        State.rules.merge(
            State.node.internalRules.rules
        ) { _, _ in fatalError("Duplicate rules, reason undefined") }
        
        // Then the node has to acknowledge ok status
        while true {
            let message = Message.poll()
            guard message.body.kind == "init" else { continue }
            State.rules[message.body.kind]!(message).dispatch()
            break
        }
        
        // Event loop
        while true {
            let message = Message.poll()
            if let callback = State.rules[message.body.kind] {
                callback(message).dispatch()
            } else {
                IO.error("Unknown message: \(message)")
            }
        }
    }
}

// MARK: - Internal message rules

public extension Node {
    @RuleSetBuilder
    var internalRules: RuleSet {
        Catch("init") { message in
            State.id = message.body.nodeID!
            State.nodes = message.body.nodeIDs!
            return message.reply(kind: "init_ok")
        }
    }
}

// MARK: - DSL

/// A temporary container for the rules. Duplicate rules are not allowed
/// and the node will crash during setup.
public struct RuleSet {
    var rules: [String: Catch.Callback] = [:]
}

/// The main building block for declarative request programming.
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
            guard !State.rules.contains(where: { $0.key == component.kind }) else {
                fatalError("Duplicate rules not allowed: \(component.kind)")
            }
            guard !ruleSet.rules.contains(where: { $0.key == component.kind }) else {
                fatalError("Duplicate rules not allowed: \(component.kind)")
            }
            ruleSet.rules[component.kind] = component.callback
        }
        return ruleSet
    }
}

