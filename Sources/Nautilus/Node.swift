
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
public enum Global {
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
        Global.node = Self()
        // First the rules need to be initialized
        Global.rules.merge(
            Global.node.rules.rules
        ) { _, _ in fatalError("Duplicate rules, reason undefined") }
        Global.rules.merge(
            Global.node.internalRules.rules
        ) { _, _ in fatalError("Duplicate rules, reason undefined") }
        
        // Then the node has to acknowledge ok status
        while true {
            let message = Message.poll()
            guard message.body.kind == "init" else { continue }
            #if ASYNC
            await Global.rules[message.body.kind]!(message)?.dispatch()
            #else
            Global.rules[message.body.kind]!(message).dispatch()
            #endif
            break
        }
        
        #if ASYNC
        let messages = AsyncStream(Message.self) { continuation in
            Task {
                while true {
                    continuation.yield(Message.poll())
                }
            }
        }
        
        while true {
            for await message in messages {
                if let callback = Global.rules[message.body.kind] {
                    Task {
                        await callback(message)?.dispatch()
                    }
                } else {
                    IO.error("Unknown message: \(message)")
                }
            }
        }
        
        #else
        // Event loop
        while true {
            let message = Message.poll()
            if let callback = Global.rules[message.body.kind] {
                callback(message).dispatch()
            } else {
                IO.error("Unknown message: \(message)")
            }
        }
        #endif
        
    }
}

// MARK: - Internal message rules

public extension Node {
    @RuleSetBuilder
    var internalRules: RuleSet {
        Catch("init") { message in
            Global.id = message.body.nodeID!
            Global.nodes = message.body.nodeIDs!
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
    public typealias Callback = (_ message: Message) -> Message?
    
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
            guard !Global.rules.contains(where: { $0.key == component.kind }) else {
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


fileprivate var stateStorage: [String: Any] = [:]
@propertyWrapper
public struct State<T> {
    let storage: String
    public var wrappedValue: T {
        get { stateStorage[storage] as! T }
        nonmutating set { stateStorage[storage] = newValue }
    }
    public init(wrappedValue: T, _ key: String) {
        stateStorage[key] = wrappedValue
        self.storage = key
    }
}
