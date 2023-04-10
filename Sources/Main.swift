
@main
extension Node {
    static func main() async throws {
        
        // The first sthing to do after starting is to wait
        // for the network to attempt an init message.
        while self.id == nil {
            let initRequest = Message.receive()
            guard initRequest.body.type == "init" else { continue }
            
            self.id = initRequest.body.nodeID!
            self.nodes = initRequest.body.nodeIDs!
            try Message.send(.initOK, previous: initRequest)
        }
        
        // The main event loop.
        while true {
            let message = Message.receive()
            
            switch message.body.type {
            case "echo":
                try Message.send(.echoOK, previous: message)
            default:
                fatalError("Unknown message type: \(message)")
            }
            
        }
    }
}
