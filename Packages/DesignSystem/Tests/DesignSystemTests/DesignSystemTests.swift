import Testing
import SwiftUI
@testable import DesignSystem

@Suite("DesignSystem tokens & utilities")
struct DesignSystemTests {

    @Test("Hex parsing produces expected sRGB components")
    func hexParsing() {
        let c = Color(hex: "#2A2A2A").resolveComponents()
        #expect(abs(c.r - 42.0 / 255) < 0.001)
        #expect(abs(c.g - 42.0 / 255) < 0.001)
        #expect(abs(c.b - 42.0 / 255) < 0.001)
        #expect(abs(c.a - 1) < 0.001)
    }

    @Test("Hex parsing tolerates missing leading hash")
    func hexNoHash() {
        let a = Color(hex: "111111").resolveComponents()
        let b = Color(hex: "#111111").resolveComponents()
        #expect(abs(a.r - b.r) < 0.001)
        #expect(abs(a.g - b.g) < 0.001)
        #expect(abs(a.b - b.b) < 0.001)
    }

    @Test("progressFill is ~15% lighter than the pill surface")
    func progressFillIsLighter() {
        let surface = DSColor.surface.resolveComponents()   // #111111 -> 17/255
        let fill = DSColor.progressFill.resolveComponents()  // #2A2A2A -> 42/255
        #expect(fill.r > surface.r)
        #expect(fill.g > surface.g)
        #expect(fill.b > surface.b)
    }

    @Test("Timecode formats sub-hour and multi-hour")
    func timecodeFormatting() {
        #expect(Timecode.string(0) == "0:00")
        #expect(Timecode.string(64) == "1:04")
        #expect(Timecode.string(3723) == "1:02:03")
        #expect(Timecode.string(-5) == "0:00")
    }

    @Test("Signed timecode shows direction")
    func signedTimecode() {
        #expect(Timecode.signedString(12) == "+0:12")
        #expect(Timecode.signedString(-90) == "-1:30")
    }
}

// Helper to read back approximate sRGB components in a cross-platform way.
private extension Color {
    func resolveComponents() -> (r: Double, g: Double, b: Double, a: Double) {
        let resolved = self.resolve(in: EnvironmentValues())
        return (Double(resolved.red), Double(resolved.green), Double(resolved.blue), Double(resolved.opacity))
    }
}
