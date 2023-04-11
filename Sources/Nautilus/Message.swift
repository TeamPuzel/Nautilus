
// MARK: - Definition

public struct Message: Codable {
    let source: String
    let destination: String
    let body: Body
    
    public struct Body: Codable {
        let kind: String
        let id: Int?
        let inReplyTo: Int?
        let nodeID: String?
        let nodeIDs: [String]?
        let echo: String?
    }
}

// MARK: - Interface

public extension Message {
    init(body: Body) {
        self.source =
        self.destination = destination
        self.body = body
    }
    func reply() -> Self {
        
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
