import FoundationModels
import BackgroundAssets
import OSLog
import System

@MainActor
class ModelManager {
    private static nonisolated let LOG = Logger(subsystem: Subsystems.AI, category: "ModelManager")
    
    private let appModel: AppModel
    private let factory: ModelFactory
  
    init(appModel: AppModel, _ factory: ModelFactory) {
        self.appModel = appModel
        self.factory = factory
    }
    
    func initializeModel() async throws -> SystemLanguageModel {
        return try await factory.create()
    }
}

@MainActor
protocol ModelFactory {
    func create() async throws -> SystemLanguageModel
}

@MainActor
class LocalModelAdapterFactory: ModelFactory {
    func create() async throws -> SystemLanguageModel {
        let url = Bundle.main.url(forResource: "mask_adapter", withExtension: "fmadapter")!
        return try! SystemLanguageModel(adapter: .init(fileURL: url))
    }
}

@MainActor
class BGAssetsFactory: ModelFactory {
    private static nonisolated let LOG = Logger(subsystem: Subsystems.AI, category: "BGAssetsFactory")
    private static nonisolated let PACK_ID = "MaskThisTestAssets"
    
    private let appModel: AppModel
    
    private var progressTask: Task<Void, Never>? = nil
    
    init(appModel: AppModel) {
        self.appModel = appModel
    }
    
    func create() async throws -> SystemLanguageModel {
        let assetPack = try await AssetPackManager.shared.assetPack(withID: Self.PACK_ID)
        
        runProgressTask()
        
        try await AssetPackManager.shared.ensureLocalAvailability(of: assetPack)
        
        progressTask?.cancel()
        progressTask = nil
        
        let adapterUrl = try AssetPackManager.shared.url(for: "Content/mask_adapter.fmadapter")
        let model = try SystemLanguageModel(adapter: .init(fileURL: adapterUrl))
        return model
    }
    
    
    private func runProgressTask() {
        progressTask = Task.detached(priority: .background) {
            let statusUpdates = AssetPackManager.shared.statusUpdates(forAssetPackWithID: Self.PACK_ID)
            for await statusUpdate in statusUpdates {
                switch statusUpdate {
                case .began(_):
                    await self.updateModelState(.downloading(fraction: 0))
                case .downloading(_, let progress):
                    await self.updateModelState(.downloading(fraction: progress.fractionCompleted))
                case .failed(_, let error):
                    await self.updateModelState(.error(text: error.localizedDescription))
                case .paused(_):
                    await self.updateModelState(.paused)
                default:
                    Self.LOG.info("Unknown status update: \(statusUpdate)")
                }
            }
        }
    }
    
    private func updateModelState(_ state: ModelState) {
        appModel.modelState = state
    }
}

@MainActor
class TestFactory: ModelFactory {
    private static nonisolated let PACK_ID = "MaskThisTestAssets"
    private static nonisolated let LOG = Logger(subsystem: Subsystems.AI, category: "BGAssetsFActory")
    
    private let appModel: AppModel
    
    private var progressTask: Task<Void, Never>? = nil
    
    init(appModel: AppModel, progressTask: Task<Void, Never>? = nil) {
        self.appModel = appModel
        self.progressTask = progressTask
    }
    
    func create() async throws -> SystemLanguageModel {
        let assetPack = try await AssetPackManager.shared.assetPack(withID: Self.PACK_ID)
        
        runProgressTask()
        
        try await AssetPackManager.shared.ensureLocalAvailability(of: assetPack)

        progressTask?.cancel()
        progressTask = nil
        
        let adapterUrl = try AssetPackManager.shared.url(for: "TestFolder/test.txt")
        let content = try String(contentsOf: adapterUrl, encoding: .utf8)
        Self.LOG.error("Assets content is: \(content)")

        return SystemLanguageModel.default
    }
    
    
    private func runProgressTask() {
        progressTask = Task.detached(priority: .background) {
            let statusUpdates = AssetPackManager.shared.statusUpdates(forAssetPackWithID: Self.PACK_ID)
            for await statusUpdate in statusUpdates {
                switch statusUpdate {
                case .began(_):
                    await self.updateModelState(.downloading(fraction: 0))
                case .downloading(_, let progress):
                    await self.updateModelState(.downloading(fraction: progress.fractionCompleted))
                case .failed(_, let error):
                    await self.updateModelState(.error(text: error.localizedDescription))
                case .paused(_):
                    await self.updateModelState(.paused)
                default:
                    Self.LOG.error("Unknown status update")
                }
            }
        }
    }

    private func updateModelState(_ state: ModelState) {
        appModel.modelState = state
    }
}
