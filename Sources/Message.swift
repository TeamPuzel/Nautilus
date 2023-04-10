
// MARK: - Definition

struct Message: Codable {
    let source: String
    let destination: String
    let body: Body
    
    struct Body: Codable {
        let type: String
        let id: Int?
        let inReplyTo: Int?
        let nodeID: String?
        let nodeIDs: [String]?
        let echo: String?
        
        init(
            type: String,
            id: Int? = nil,
            inReplyTo: Int? = nil,
            nodeID: String? = nil,
            nodeIDs: [String]? = nil,
            echo: String? = nil
        ) {
            self.type = type
            self.id = id
            self.inReplyTo = inReplyTo
            self.nodeID = nodeID
            self.nodeIDs = nodeIDs
            self.echo = echo
        }
    }
}

// MARK: - Encoding

extension Message {
    enum CodingKeys: String, CodingKey {
        case source = "src"
        case destination = "dest"
        case body
    }
}

extension Message.Body {
    enum CodingKeys: String, CodingKey {
        case type
        case id = "msg_id"
        case inReplyTo = "in_reply_to"
        case nodeID = "node_id"
        case nodeIDs = "node_ids"
        case echo
    }
}

// MARK: - Communication

import Foundation
import Darwin

extension Message {
    
    enum Kind {
        case initOK
        case echoOK
    }
    
    static func send(_ kind: Kind, previous: Message? = nil) throws {
        switch kind {
        case .initOK:
            try deliver(Message(
                source: Node.id!,
                destination: previous!.source,
                body: Body(type: "init_ok", inReplyTo: previous!.body.id)
            ))
        case .echoOK:
            try deliver(Message(
                source: Node.id!,
                destination: previous!.source,
                body: Body(
                    type: "echo_ok",
                    id: .random(in: 1...Int.max),
                    inReplyTo: previous!.body.id,
                    echo: previous!.body.echo
                )
            ))
        }
    }
    
    private static func deliver(_ message: Message) throws {
        print(String(data: try JSONEncoder().encode(message), encoding: .utf8)!)
    }
    
    static func receive() -> Message {
        let json = JSONDecoder()
        
        var message: Message? = nil
        while message == nil {
            
            var input: String = ""
            while input.count == 0 || !input.validateJSON() {
                guard let line = readLine() else { continue }
                guard line.matches(of: try! Regex("{")).count > 1 else { continue }
                input += line
            }
            
            guard let data = input.data(using: .utf8) else { continue }
            
            do { message = try json.decode(Message.self, from: data) } catch {
                errorPrint(error.localizedDescription)
                continue
            }
            
        }
        return message!
    }
}

// MARK: - IO

func errorPrint(_ string: String) {
    (string + "\n").withCString { pointer in
        fputs(pointer, stderr)
        fflush(stderr)
    }
}

func print(_ string: String) {
    (string + "\n").withCString { pointer in
        fputs(pointer, stdout)
        fflush(stdout)
    }
}

func read() -> String? {
    var reply: UnsafeMutablePointer<CChar>? = nil
    var string: String? = nil
    withUnsafeTemporaryAllocation(of: CChar.self, capacity: 1300) { pointer in
        reply = fgets(pointer.baseAddress, 1300, stdin)
        pointer[1299] = 0
        string = String(cString: Array(pointer))
    }
    guard reply != nil else { return nil }
    return string
}

extension String {
    func validateJSON() -> Bool {
        let l = try! self.matches(of: Regex("{")).count
        let r = try! self.matches(of: Regex("}")).count
        if l == r { return true } else { return false }
    }
}

// { "src": "c1", "dest": "n1", "body": { "type": "init", "msg_id": 1, "node_id": "n1", "node_ids": ["n1", "n2", "n3"] } }
// { "src": "c1", "dest": "n1", "body": { "type": "echo", "msg_id": 1, "echo": "Please echo 35" } }
