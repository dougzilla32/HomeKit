import Foundation
import PromiseKit
import HomeKit

public enum HomeKitError: Error {
    case permissionDeined
}

extension HMHomeManager {
    public func homes() -> Promise<[HMHome]> {
        return HMHomeManagerProxy().promise
    }
    
    #if !os(tvOS) && !os(watchOS)

    @available(iOS 8.0, *)
    public func addHome(withName name: String) -> Promise<HMHome> {
        return Promise { seal in
            self.addHome(withName: name, completionHandler: seal.resolve)
        }
    }
    
    @available(iOS 8.0, *)
    public func removeHome(_ home: HMHome) -> Promise<Void> {
        return Promise { seal in
            self.removeHome(home, completionHandler: seal.resolve)
        }
    }
    
    @available(iOS 8.0, *)
    public func updatePrimaryHome(_ home: HMHome) -> Promise<Void> {
        return Promise { seal in
            self.updatePrimaryHome(home, completionHandler: seal.resolve)
        }
    }
    
    #endif
}

internal class HMHomeManagerProxy: PromiseProxy<[HMHome]>, HMHomeManagerDelegate {
    
    fileprivate let manager: HMHomeManager

    override init() {
        self.manager = HMHomeManager()
        super.init()
        self.manager.delegate = self
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 20.0) { [weak self] in
            self?.reject(HomeKitError.permissionDeined)
        }
    }
    
    func homeManagerDidUpdateHomes(_ manager: HMHomeManager) {
        fulfill(manager.homes)
    }
}
