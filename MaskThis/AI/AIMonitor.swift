import FoundationModels
import Foundation

@MainActor
class AIMonitor {
    private let appModel: AppModel
    private let modelManager: ModelManager
    
    var inference: AIInferenceEngine?
    
    init(_ appModel: AppModel, _ modelManager: ModelManager) {
        self.appModel = appModel
        self.modelManager = modelManager
    }
    
    func setupAIMonitoring() {
        _ = processModelAvailability()
        
        Task.detached(priority: .background) {
            while true {
                let currentStatus = await self.processModelAvailability()
                if case .ready = currentStatus {
                    await self.initializeModel()
                }
                await Util.delay(.seconds(1))
            }
        }
    }
    
    private func processModelAvailability() -> AppleIntelligenceStatus {
        let availability = SystemLanguageModel.default.availability
        if case .available = availability {
            appModel.aiStatus = .ready
        } else if case .unavailable(let unavailableReason) = availability {
            appModel.aiStatus = .unavailable(reason: unavailableReason)
        }
        return appModel.aiStatus
    }
    
    private func initializeModel() async {
        if let _ = inference {
            return
        }
        
        do {
            let model = try await modelManager.initializeModel()
            inference = AIInferenceEngine(model)
            appModel.modelState = .ready
        } catch {
            appModel.modelState = .error(text: error.localizedDescription)
        }
    }
}
