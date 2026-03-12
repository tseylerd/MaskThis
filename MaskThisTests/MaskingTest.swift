import Testing
import OSLog
import Foundation
import FoundationModels

@testable import MaskThis

@Suite("MaskingTest", .serialized)
struct MaskingTest {
    private static let LOG = Logger(subsystem: Subsystems.TEST, category: "MaskingTest")
    private let model: SystemLanguageModel
    
    init() throws {
        self.model = try TestUtil.createModel()
    }
    
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
    
    @Test
    func longTextWithPII() async throws {
        let result = try await process("""
Alice was beginning to get very tired of sitting by her sister on the bank, and of having nothing to do: once or twice she had peeped into the book her sister was reading, but it had no pictures or conversations in it, 'and what is the use of a book,' thought Alice 'without pictures or conversations?'

That morning, Alice had received a note from her friend John. 'Dear Alice,' it began. She had tucked it into her apron pocket before coming to sit on the bank.

So she was considering in her own mind (as well as she could, for the hot day made her feel very sleepy and stupid), whether the pleasure of making a daisy-chain would be worth the trouble of getting up and picking the daisies, when suddenly a White Rabbit with pink eyes ran close by her.

There was nothing so very remarkable in that; nor did Alice think it so very much out of the way to hear the Rabbit say to itself, 'Oh dear! Oh dear! I shall be late!' (when she thought it over afterwards, it occurred to her that she ought to have wondered at this, but at the time it all seemed quite natural); but when the Rabbit actually took a watch out of its waistcoat-pocket, and looked at it, and then hurried on, Alice started to her feet, for it flashed across her mind that she had never before seen a rabbit with either a waistcoat-pocket, or a watch to take out of it, and burning with curiosity, she ran across the field after it, and fortunately was just in time to see it pop down a large rabbit-hole under the hedge.

In another moment down went Alice after it, never once considering how in the world she was to get out again.

The rabbit-hole went straight on like a tunnel for some way, and then dipped suddenly down, so suddenly that Alice had not a moment to think about stopping herself before she found herself falling down a very deep well.
""")
        #expect(!result.contains("Alice"))
        #expect(!result.contains("John"))
        
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
    
    @Test func tooManyChunksThrown() async throws {
        let code = """
    !?.!?.!?.!?.
    """
        await #expect(throws: InferenceError.textIsTooBig) {
            try await process(code, 1)
        }
    }
    
    private func process(_ text: String, _ maxChunkLength: Int = AIInferenceEngine.CHUNK_SIZE) async throws -> String {
        let engine = await AIInferenceEngine(model, maxChunkLength)
        return try await engine.mask(text)
    }
    
    private func log(_ string: String) {
        Self.LOG.info("\(string)")
    }
}
