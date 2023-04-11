
#if canImport(Darwin)
import Darwin
#elseif canImport(Glibc)
import Glibc
#endif

enum IO {
    @inline(__always)
    static func error(_ string: String) {
        (string + "\n").withCString { pointer in
            fputs(pointer, stderr)
            fflush(stderr)
        }
    }
    @inline(__always)
    static func output(_ string: String) {
        (string + "\n").withCString { pointer in
            fputs(pointer, stdout)
            fflush(stdout)
        }
    }
    @inline(__always)
    static func _input() -> String? {
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
}
