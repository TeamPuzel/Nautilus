
// MARK: - Definition

/// The data structure of Maelstrom protocol messages.
public struct Message: Codable {
    public let source: String
    public let destination: String
    public let body: Body
    
    public struct Body: Codable {
        public let kind: String
        public let id: Int?
        public let inReplyTo: Int?
        public let nodeID: String?
        public let nodeIDs: [String]?
        public let echo: String?
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
    public init(
        source: String,
        destination: String,
        kind: String,
        id: Int? = nil,
        inReplyTo: Int? = nil,
        nodeID: String? = nil,
        nodeIDs: [String]? = nil,
        echo: String? = nil
    ) {
        self.source = source
        self.destination = destination
        self.body = Body(
            kind: kind,
            id: id,
            inReplyTo: inReplyTo,
            nodeID: nodeID,
            nodeIDs: nodeIDs,
            echo: echo
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
        echo: String? = nil
    ) {
        
        self.source = State.id
        self.destination = destination
        self.body = Body(
            kind: kind,
            id: .random(in: 1...Int.max),
            inReplyTo: inReplyTo,
            nodeID: nil,
            nodeIDs: sendNodeIDs ? State.nodes : nil,
            echo: echo
        )
    }
    
    /// Convenience method that automatically fills in the details necessary to reply directly to the sender.
    /// - Parameters:
    ///   - kind: Identifies the type of message to the receiver.
    ///   - sendNodeIDs: If the array of known nodes should be sent.
    ///   - echo: Echo message content.
    /// - Returns: New instance of `Message` ready to be sent.
    func reply(
        kind: String,
        sendNodeIDs: Bool = false,
        echo: String? = nil
    ) -> Message {
        Message(
            destination: self.source,
            kind: kind,
            inReplyTo: self.body.id,
            sendNodeIDs: sendNodeIDs,
            echo: echo
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
    static func dispatch(_ message: Message) {
        IO.output(String(data: try! encoder.encode(message), encoding: .utf8)!)
    }
    func dispatch() {
        IO.output(String(data: try! encoder.encode(self), encoding: .utf8)!)
    }
}
