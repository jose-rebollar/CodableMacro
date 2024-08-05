import SwiftCompilerPlugin
import SwiftSyntax
import SwiftSyntaxBuilder
import SwiftSyntaxMacros

public enum EGCodableMacro: ExtensionMacro {
    public static func expansion(
        of node: AttributeSyntax,
        attachedTo declaration: some DeclGroupSyntax,
        providingExtensionsOf type: some TypeSyntaxProtocol,
        conformingTo protocols: [TypeSyntax],
        in context: some MacroExpansionContext
    ) throws -> [ExtensionDeclSyntax] {
        
        let memberList = declaration.memberBlock.members
        
        let cases = memberList.compactMap({ member -> String? in
            // is a property
            guard
                let propertyName = member
                    .decl.as(VariableDeclSyntax.self)?
                    .bindings.first?
                    .pattern.as(IdentifierPatternSyntax.self)?.identifier.text
            else {
                return nil
            }
            
            if let _ = member.decl.as(VariableDeclSyntax.self)?.attributes.first(where: { element in
                element.as(AttributeSyntax.self)?.attributeName
                    .as(IdentifierTypeSyntax.self)?.description
                    .trimmingCharacters(in: .whitespacesAndNewlines) == "EGExcluded"
            }) {
                return nil
            }
            
            // if it has a CodableKey macro on it
            if let customKeyMacro = member.decl.as(VariableDeclSyntax.self)?.attributes.first(where: { element in
                element.as(AttributeSyntax.self)?.attributeName
                    .as(IdentifierTypeSyntax.self)?.description
                    .trimmingCharacters(in: .whitespacesAndNewlines) == "EGKey"
            }) {
                
                // Uses the value in the Macro
                let customKeyValue = customKeyMacro.as(AttributeSyntax.self)!
                    .arguments!.as(LabeledExprListSyntax.self)!
                    .first!
                    .expression
                
                return "case \(propertyName) = \(customKeyValue)"
            } else {
                return "case \(propertyName)"
            }
        })
        
        let codableExtension = try ExtensionDeclSyntax(
          """
          extension \(type.trimmed): Codable {
                enum CodingKeys: String, CodingKey {
                  \(raw: cases.joined(separator: "\n"))
                }
          }
          """)
        
        return [ codableExtension ]
    }
}

public struct EGKeyMacro: PeerMacro {
    public static func expansion(
        of node: AttributeSyntax,
        providingPeersOf declaration: some DeclSyntaxProtocol,
        in context: some MacroExpansionContext
    ) throws -> [DeclSyntax] {
        // Does nothing, used only to decorate members with data
        return []
    }
}

public struct EGExcludedMacro: PeerMacro {
    public static func expansion(
        of node: AttributeSyntax,
        providingPeersOf declaration: some DeclSyntaxProtocol,
        in context: some MacroExpansionContext
    ) throws -> [DeclSyntax] {
        // Does nothing, used only to decorate members with data
        return []
    }
}

@main
struct CodableMacroPlugin: CompilerPlugin {
    let providingMacros: [Macro.Type] = [
        EGCodableMacro.self,
        EGKeyMacro.self,
        EGExcludedMacro.self
    ]
}
