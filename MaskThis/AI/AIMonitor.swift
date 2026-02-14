import FoundationModels
import Foundation

@Observable
@MainActor
class AIMonitor {
    private let appModel: AppModel
    private let modelFactory: ModelFactory
    
    var inference: AIInferenceEngine?
    
    init(_ appModel: AppModel, _ modelFactory: ModelFactory) {
        self.appModel = appModel
        self.modelFactory = modelFactory
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
            appModel.markAppleIntelligenceReady()
        } else if case .unavailable(let unavailableReason) = availability {
            appModel.markAppleIntelligenceUnavailable(unavailableReason)
        }
        return appModel.aiStatus
    }
    
    private func initializeModel() async {
        if let _ = inference {
            return
        }
        
        do {
            let model = try await modelFactory.create()
            inference = AIInferenceEngine(model)
            appModel.modelState = .ready
        } catch {
            appModel.modelState = .error(text: error.localizedDescription)
        }
    }
}
