import Testing
import OSLog
import Foundation
import FoundationModels

@testable import MaskThis

@Suite("MaskingTest", .serialized)
struct MaskingTest {
    private static let LOG = Logger(subsystem: Subsystems.TEST, category: "MaskingTest")
    private static let MODEL = SystemLanguageModel(adapter: try! .init(fileURL: Bundle.main.url(forResource: "mask_adapter", withExtension: "fmadapter")!))
    
    @Test
    func simpleNoPII() async throws {
        let result = try await process("Name")
        Self.LOG.info("\(result)")
    }
    
    @Test
    func simplePII() async throws {
        let result = try await process("My name is Dima")
        #expect(!result.contains("Dima"))
        
        Self.LOG.info("\(result)")
    }
    
    @Test
    func email() async throws {
        let result = try await process("Please send the response to john.doe@gmail.com")
        #expect(!result.contains("john.doe"))
        
        Self.LOG.info("\(result)")
    }
    
    @Test
    func manyPII() async throws {
        let result = try await process("""
Hello!

My name is John.
Please, respond to my request regarding the car with the number A123BC.

Please send the response to john.doe@gmail.com

My phone number is:
+1 234 567 89

Also, you can login into my account using password 12345.

Best,
John
""")
        #expect(!result.contains("John"))
        #expect(!result.contains("A123BC"))
        #expect(!result.contains("john.doe"))
        #expect(!result.contains("+1 234 567 89"))
        #expect(!result.contains("12345"))
        
        Self.LOG.info("\(result)")
    }
    
    @Test func noPII() async throws {
        let original = """
Hello!

Could you let me know when you are free?

Thanks.
"""
        let result = try await process(original)
        
        #expect(result == original)
        
        log(result)
    }
    
    @Test func code() async throws {
        let code = """
    fun launch() {
        let result = launchAsync()
        result.await()
    }
    """
        let result = try await process(code)
        
        #expect(result == code)
        
        log(result)
    }
    
    @Test func codeSwift() async throws {
        let code = """
    fun launch() async {
        let result = launchAsync()
        await result.value
    }
    """
        let result = try await process(code)
        
        #expect(result == code)
        
        log(result)
    }
    
    private func process(_ text: String) async throws -> String {
        let engine = await AIInferenceEngine(Self.MODEL)
        return try await engine.mask(text)
    }
    
    private func log(_ string: String) {
        Self.LOG.info("\(string)")
    }
}
