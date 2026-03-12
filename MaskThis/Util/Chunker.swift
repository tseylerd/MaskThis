nonisolated class Chunker {
    private init() { }
    
    static func chunks(from text: String, by separators: [Character], withMaxSybolsOf limit: Int) -> [String] {
        guard text.count > limit else {
            return [text]
        }
        
        let initialChunks = initialSplit(text, separators, limit, 0)
        var currentText = ""
        var currentIndex = 0
        var result: [String] = []
        
        while currentIndex < initialChunks.count {
            let currentElement = initialChunks[currentIndex]
            let currentTextCount = currentText.count
            currentIndex += 1
            
            guard currentTextCount + currentElement.count > limit else {
                currentText += currentElement
                continue
            }
            
            result.append(currentText)
            currentText = currentElement
        }
        
        if !currentText.isEmpty {
            result.append(currentText)
        }
        
        return result
    }
    
    private static func initialSplit(_ text: String, _ separators: [Character], _ limit: Int, _ separatorIndex: Int) -> [String] {
        guard separatorIndex < separators.count else {
            return splitByLimit(text, limit)
        }
        
        let separator = separators[separatorIndex]
        let chunks = splitBySymbol(text, separator)
        return chunks.flatMap { c in initialSplit(c, separators, limit, separatorIndex + 1) }
    }
    
    private static func splitBySymbol(_ text: String, _ separator: Character) -> [String] {
        let allIndices = text.indices(of: separator)
        var start = text.startIndex
        var result: [String] = []
        for range in allIndices.ranges {
            let rangeStart = range.upperBound
            result.append(String(text[start..<rangeStart]))
            
            start = rangeStart
        }
        if start < text.endIndex {
            result.append(String(text[start..<text.endIndex]))
        }
        return result
    }
    
    private static func splitByLimit(_ text: String, _ limit: Int) -> [String] {
        guard text.count > limit else {
            return [text]
        }
        
        var result: [String] = []
        for i in stride(from: 0, to: text.count, by: limit) {
            let startIndex = text.index(text.startIndex, offsetBy: i)
            let endIndex = text.index(text.startIndex, offsetBy: min(i + limit, text.count))
            result.append(String(text[startIndex..<endIndex]))
        }
        return result
    }
}
