
import Nautilus

@main
struct Echo: Node {
    var rules: RuleSet {
        Catch("echo") { message in
            message.reply(kind: "echo_ok", echo: message.body.echo)
        }
    }
}
