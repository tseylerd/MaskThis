import FoundationModels
import Foundation
import OSLog
import BackgroundAssets
import System

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

open class BGAssetsBasedFactory: ModelFactory {
    fileprivate static nonisolated let LOG = Logger(subsystem: Subsystems.AI, category: "BGAssetsFactory")
    
    private let appModel: AppModel
    private let assetsId: String
    private let path: String
    
    private var progressTask: Task<Void, Never>? = nil
    
    init(appModel: AppModel, path: String, assets: String) {
        self.appModel = appModel
        self.path = path
        self.assetsId = assets
    }
    
    func create() async throws -> SystemLanguageModel {
        let assetPack = try await AssetPackManager.shared.assetPack(withID: assetsId)
        
        runProgressTask()
        
        try await AssetPackManager.shared.ensureLocalAvailability(of: assetPack)
        
        progressTask?.cancel()
        progressTask = nil
        
        let adapterUrl = try AssetPackManager.shared.url(for: .init(path))
        let model = try createModel(adapterUrl)
        return model
    }
    
    open func createModel(_ url: URL) throws -> SystemLanguageModel {
        try SystemLanguageModel(adapter: .init(fileURL: url))
    }
    
    private func runProgressTask() {
        progressTask = Task.detached(priority: .background) {
            let statusUpdates = AssetPackManager.shared.statusUpdates(forAssetPackWithID: self.assetsId)
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
class BGAssetsFactory: BGAssetsBasedFactory {
    init(appModel: AppModel) {
        super.init(appModel: appModel, path: "mask_adapter.fmadapter", assets: "MaskThisModelAdapter262")
    }
}

@MainActor
class TestFactory: BGAssetsBasedFactory {
    init(appModel: AppModel) {
        super.init(appModel: appModel, path: "TestFolder/test.txt", assets: "MaskThisTestAssets")
    }
    
    override func createModel(_ url: URL) throws -> SystemLanguageModel {
        let content = try String(contentsOf: url, encoding: .utf8)
        Self.LOG.error("Assets content is: \(content)")
        
        return SystemLanguageModel.default
    }
}
