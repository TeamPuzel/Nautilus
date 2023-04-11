
// MARK: - Definition

/// The data structure of Maelstrom protocol messages.
public struct Message: Codable {
    public var source: String
    public var destination: String
    public var body: Body
    
    public struct Body: Codable {
        public var kind: String
        public var id: Int?
        public var inReplyTo: Int?
        public var nodeID: String?
        public var nodeIDs: [String]?
        public var echo: String?
        public var code: Int?
        public var text: String?
        public var genID: Int?
        public var message: Int?
        public var messages: [Int]?
        public var topology: [String: [String]]?
    }
    
    /// The data structure of Maelstrom protocol messages.
    /// - Parameters:
    ///   - source: Where the message is originating from.
    ///   - destination: Where the message is addressed.
    ///   - kind: Identifies the type of message to the receiver.
    ///   - id: The ID of the message.
    ///   - inReplyTo: Message ID of the message being replied to.
    ///   - nodeID: Used to configure new nodes with an ID.
    ///   - nodeIDs: An array containing  IDs of all known nodes.
    ///   - echo: Echo message content.
    ///   - code: Error code.
    ///   - text: Text content of the message.
    ///   - genID: Generated ID for requests.
    ///   - message: Broadcast message.
    ///   - messages: Broadcast messages.
    public init(
        source: String,
        destination: String,
        kind: String,
        id: Int? = nil,
        inReplyTo: Int? = nil,
        nodeID: String? = nil,
        nodeIDs: [String]? = nil,
        echo: String? = nil,
        code: Int? = nil,
        text: String? = nil,
        genID: Int? = nil,
        message: Int? = nil,
        messages: [Int]? = nil,
        topology: [String: [String]]? = nil
    ) {
        self.source = source
        self.destination = destination
        self.body = Body(
            kind: kind,
            id: id,
            inReplyTo: inReplyTo,
            nodeID: nodeID,
            nodeIDs: nodeIDs,
            echo: echo,
            code: code,
            text: text,
            genID: genID,
            message: message,
            messages: messages,
            topology: topology
        )
    }
    
}

// MARK: - Interface

public extension Message {
    init(
        destination: String,
        kind: String,
        inReplyTo: Int? = nil,
        sendNodeIDs: Bool = false,
        echo: String? = nil,
        code: Int? = nil,
        text: String? = nil,
        genID: Int? = nil,
        message: Int? = nil,
        messages: [Int]? = nil,
        topology: [String: [String]]? = nil
    ) {
        
        self.source = Global.id
        self.destination = destination
        self.body = Body(
            kind: kind,
            id: .random(in: 1...Int.max),
            inReplyTo: inReplyTo,
            nodeID: nil,
            nodeIDs: sendNodeIDs ? Global.nodes : nil,
            echo: echo,
            code: code,
            text: text,
            genID: genID,
            message: message,
            messages: messages,
            topology: topology
        )
    }
    
    /// Convenience method that automatically fills in the details necessary to reply directly to the sender.
    /// - Parameters:
    ///   - kind: Identifies the type of message to the receiver.
    ///   - sendNodeIDs: If the array of known nodes should be sent.
    ///   - echo: Echo message content.
    ///   - code: Error code.
    ///   - text: Text content of the message.
    ///   - genID: Generated ID for requests.
    ///   - message: Broadcast message.
    ///   - messages: Broadcast messages.
    /// - Returns: New instance of `Message` ready to be sent.
    func reply(
        kind: String,
        sendNodeIDs: Bool = false,
        echo: String? = nil,
        code: Int? = nil,
        text: String? = nil,
        genID: Int? = nil,
        message: Int? = nil,
        messages: [Int]? = nil
    ) -> Message {
        Message(
            destination: self.source,
            kind: kind,
            inReplyTo: self.body.id,
            sendNodeIDs: sendNodeIDs,
            echo: echo,
            code: code,
            text: text,
            genID: genID,
            message: message,
            messages: messages
        )
    }
}

// MARK: - Encoding

public extension Message {
    enum CodingKeys: String, CodingKey {
        case source = "src"
        case destination = "dest"
        case body
    }
}

public extension Message.Body {
    enum CodingKeys: String, CodingKey {
        case kind = "type"
        case id = "msg_id"
        case inReplyTo = "in_reply_to"
        case nodeID = "node_id"
        case nodeIDs = "node_ids"
        case echo
        case code
        case text
        case genID = "id"
        case message
        case messages
        case topology
    }
}

// MARK: - Communication

import Foundation

fileprivate let encoder = JSONEncoder()
fileprivate let decoder = JSONDecoder()

extension Message {
    static func poll() -> Message {
        while true {
            guard let input = readLine() else { continue }
            do {
                return try decoder.decode(Message.self, from: input.data(using: .utf8)!)
            } catch {
                IO.error("""
                Error:
                \(error)
                Could not decode:
                \(input)
                """
                )
            }
        }
    }
    public static func dispatch(_ message: Message) {
        IO.output(String(data: try! encoder.encode(message), encoding: .utf8)!)
    }
    
    #if ASYNC
    @MainActor
    public func dispatch() async {
        IO.output(String(data: try! encoder.encode(self), encoding: .utf8)!)
    }
    #else
    public func dispatch() {
        IO.output(String(data: try! encoder.encode(self), encoding: .utf8)!)
    }
    #endif
}
