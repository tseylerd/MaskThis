import FoundationModels
import Testing
import Foundation
@testable import MaskThis

struct TestUtil {
    private init() { }
    
    static func createModel() throws -> SystemLanguageModel {
        let id = try #require(Util.compatibleAdapterIdentifier(Constants.adapterName))
        let url = try #require(Bundle.main.url(forResource: id, withExtension: "fmadapter"))
        let adapter = try SystemLanguageModel.Adapter(fileURL: url)
        return SystemLanguageModel(adapter: adapter)
    }
}
