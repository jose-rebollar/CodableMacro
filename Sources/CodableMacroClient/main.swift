import CodableMacro

@EGCodable
struct Response {
    var name: String?
    @EGKey(name: "first_name") var firstName: String?
    @EGExcluded var address: Int?
}
