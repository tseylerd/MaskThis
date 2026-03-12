import Testing
import OSLog
import Foundation
import FoundationModels

@testable import MaskThis

@Suite("ChunkerTest", .serialized)
struct ChunkerTest {
    @Test
    func underLimitTextStaysTheSame() async throws {
        let text = "My small text.!?"
        let chunks = Chunker.chunks(from: text, by: AIInferenceEngine.SENTENCE_SEPARATORS, withMaxSybolsOf: AIInferenceEngine.CHUNK_SIZE)
        
        
        #expect(chunks.count == 1)
        #expect(text == chunks[0])
    }
    
    @Test
    func correctlySplitHumanReadableText() async throws {
        let text = "Hello! How are you?"
        let chunks = Chunker.chunks(from: text, by: AIInferenceEngine.SENTENCE_SEPARATORS, withMaxSybolsOf: " How are you?".count)
        
        #expect(chunks.count == 2)
        #expect(chunks[0] == "Hello!")
        #expect(chunks[1] == " How are you?")
        
        let joined = chunks.joined(separator: "")
        #expect(joined == text)
    }
    
    @Test
    func nonsenseStaysTheSame() async throws {
        let text = "!?.!?...!???!"
        let chunks = Chunker.chunks(from: text, by: AIInferenceEngine.SENTENCE_SEPARATORS, withMaxSybolsOf: 2)
        
        #expect(chunks.count == 7)
        #expect(chunks[0] == "!?")
        #expect(chunks[1] == ".!")
        #expect(chunks[2] == "?")
        #expect(chunks[3] == "..")
        #expect(chunks[4] == ".!")
        #expect(chunks[5] == "??")
        #expect(chunks[6] == "?!")
        
        let joined = chunks.joined(separator: "")
        #expect(joined == text)
    }
    
    @Test
    func emptyTextReturnsItself() async throws {
        let text = ""
        let chunks = Chunker.chunks(from: text, by: AIInferenceEngine.SENTENCE_SEPARATORS, withMaxSybolsOf: 2)
        
        #expect(chunks.count == 1)
        #expect(chunks[0] == "")
    }
    
    @Test
    func spacesArePreserved() async throws {
        let text = "   My! Test? Text...!? and what!>?    "
        let chunks = Chunker.chunks(from: text, by: AIInferenceEngine.SENTENCE_SEPARATORS, withMaxSybolsOf: 10)
        
        #expect(chunks.count == 5)
        #expect(chunks[0] == "   My!")
        #expect(chunks[1] == " Test?")
        #expect(chunks[2] == " Text...!?")
        #expect(chunks[3] == " and what!")
        #expect(chunks[4] == ">?    ")
        
        #expect(chunks.joined(separator: "") == text)
    }
    
    @Test
    func chunksAreSplitByLengthAsWell() async throws {
        let text = "    Word1!   Word2?   Word3.   Word4;    "
        let chunks = Chunker.chunks(from: text, by: AIInferenceEngine.SENTENCE_SEPARATORS, withMaxSybolsOf: 4)
        
        #expect(chunks.count == 13)
        #expect(chunks[0] == "    ")
        #expect(chunks[1] == "Word")
        #expect(chunks[2] == "1!")
        #expect(chunks[3] == "   W")
        #expect(chunks[4] == "ord2")
        #expect(chunks[5] == "?")
        #expect(chunks[6] == "   W")
        #expect(chunks[7] == "ord3")
        #expect(chunks[8] == ".")
        #expect(chunks[9] == "   W")
        #expect(chunks[10] == "ord4")
        #expect(chunks[11] == ";")
        #expect(chunks[12] == "    ")

        #expect(chunks.joined(separator: "") == text)
    }
}
