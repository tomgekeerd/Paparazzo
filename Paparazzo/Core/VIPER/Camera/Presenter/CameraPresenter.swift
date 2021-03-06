import ImageSource

final class CameraPresenter: CameraModuleInput {
    
    private let interactor: CameraInteractor
    
    weak var view: CameraViewInput? {
        didSet {
            setUpView()
        }
    }
    
    // MARK: - Init
    
    init(interactor: CameraInteractor) {
        self.interactor = interactor
    }
    
    // MARK: - CameraModuleInput
    
    func getOutputParameters(completion: @escaping (CameraOutputParameters?) -> ()) {
        interactor.getOutputParameters(completion: completion)
    }
    
    func setCameraOutputNeeded(_ isCameraOutputNeeded: Bool) {
        interactor.setCameraOutputNeeded(isCameraOutputNeeded)
    }
    
    func isFlashAvailable(completion: @escaping (Bool) -> ()) {
        interactor.isFlashAvailable(completion: completion)
    }
    
    func isFlashEnabled(completion: @escaping (Bool) -> ()) {
        interactor.isFlashEnabled(completion: completion)
    }
    
    func setFlashEnabled(_ enabled: Bool, completion: ((_ success: Bool) -> ())?) {
        interactor.setFlashEnabled(enabled, completion: completion)
    }
    
    func canToggleCamera(completion: @escaping (Bool) -> ()) {
        interactor.canToggleCamera(completion: completion)
    }
    
    func toggleCamera(completion: @escaping (_ newOutputOrientation: ExifOrientation) -> ()) {
        interactor.toggleCamera { [weak self] newOutputOrientation in
            self?.view?.setOutputOrientation(newOutputOrientation)
            completion(newOutputOrientation)
        }
    }
    
    func takePhoto(completion: @escaping (MediaPickerItem?) -> ()) {
        interactor.takePhoto(completion: completion)
    }
    
    func setPreviewImagesSizeForNewPhotos(_ size: CGSize) {
        interactor.setPreviewImagesSizeForNewPhotos(size)
    }
    
    func mainModuleDidAppear(animated: Bool) {
        view?.mainModuleDidAppear(animated: animated)
    }
    
    // MARK: - Private
    
    private func setUpView() {
        
        view?.setAccessDeniedTitle("Geen toegang")
        view?.setAccessDeniedMessage("Er is geen toegang gegeven tot de camera, verander uw privacy instellingen.")
        view?.setAccessDeniedButtonTitle("Ga naar instellingen")
        
        view?.onAccessDeniedButtonTap = {
            if let url = URL(string: UIApplicationOpenSettingsURLString) {
                UIApplication.shared.openURL(url)
            }
        }
        
        interactor.getOutputParameters { [weak self] parameters in
            if let parameters = parameters {
                self?.view?.setOutputParameters(parameters)
            } else {
                self?.view?.setAccessDeniedViewVisible(true)
            }
        }
        
        interactor.observeDeviceOrientation { [weak self] deviceOrientation in
            self?.view?.adjustForDeviceOrientation(deviceOrientation)
        }
    }
}
