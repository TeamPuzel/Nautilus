
import Nautilus

@main
struct UniqueID: Node {
    var rules: RuleSet {
        Catch("generate") { message in
            message.reply(kind: "generate_ok", genID: .random(in: 1...Int.max))
        }
    }
}
