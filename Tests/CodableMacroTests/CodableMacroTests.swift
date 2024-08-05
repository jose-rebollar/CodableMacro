import SwiftSyntax
import SwiftSyntaxBuilder
import SwiftSyntaxMacros
import SwiftSyntaxMacrosTestSupport
import XCTest

// Macro implementations build for the host, so the corresponding module is not available when cross-compiling. Cross-compiled tests may still make use of the macro itself in end-to-end tests.
#if canImport(CodableMacroMacros)
import CodableMacroMacros

let testMacros: [String: Macro.Type] = [
    "EGCodable": EGCodableMacro.self,
    "EGKey": EGKeyMacro.self,
    "EGExcluded": EGExcludedMacro.self,
]
#endif

final class CodableMacroTests: XCTestCase {
    func testMacro() throws {
        #if canImport(CodableMacroMacros)
        assertMacroExpansion(
            """
            @EGCodable
            struct Response {
                var name: String?
                
                @EGKey(name: "first_name")
                var firstName: String?

                @EGExcluded
                var address: Int?
            }
            """,
            expandedSource: 
            """
            @EGCodable
            struct Response {
                var name: String?
                
                @EGKey(name: "first_name")
                var firstName: String?

                @EGExcluded
                var address: Int?
            }
            
            extension Response: Codable {
                  enum CodingKeys: String, CodingKey {
                    case name
                    case firstName = "first_name"
                  }
            }
            """,
            macros: testMacros
        )
        #else
        throw XCTSkip("macros are only supported when running tests for the host platform")
        #endif
    }
}
