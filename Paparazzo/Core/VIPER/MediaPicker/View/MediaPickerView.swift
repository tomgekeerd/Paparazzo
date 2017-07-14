import ImageSource
import UIKit

final class MediaPickerView: UIView {
    
    // MARK: - Subviews
    
    private let cameraControlsView = CameraControlsView()
    private let photoControlsView = PhotoControlsView()
    
    private let photoLibraryPeepholeView = UIImageView()
    private let photoTitleLabel = UILabel()
    private let flashView = UIView()
    
    private let thumbnailRibbonView: ThumbnailsView
    private let photoPreviewView: PhotoPreviewView
    
    // MARK: - Constants
    
    private let cameraAspectRatio = CGFloat(4) / CGFloat(3)
    
    private let bottomPanelMinHeight: CGFloat = {
        let iPhone5ScreenSize = CGSize(width: 320, height: 568)
        return iPhone5ScreenSize.height - iPhone5ScreenSize.width / 0.75
    }()
    
    private let controlsCompactHeight = CGFloat(54) // (iPhone 4 height) - (iPhone 4 width) * 4/3 (photo aspect ratio) = 53,333...
    private let controlsExtendedHeight = CGFloat(80)
    
    // MARK: - Helpers
    
    private var mode = MediaPickerViewMode.camera
    private var deviceOrientation = DeviceOrientation.portrait
    
    // MARK: - UIView
    
    override init(frame: CGRect) {
        
        thumbnailRibbonView = ThumbnailsView()
        photoPreviewView = PhotoPreviewView()
        
        super.init(frame: .zero)
        
        backgroundColor = .white
        
        flashView.backgroundColor = .white
        flashView.alpha = 0
        
        photoTitleLabel.textColor = .white
        photoTitleLabel.layer.shadowOffset = .zero
        photoTitleLabel.layer.shadowOpacity = 0.5
        photoTitleLabel.layer.shadowRadius = 1
        photoTitleLabel.layer.masksToBounds = false
        photoTitleLabel.alpha = 0
        
        photoLibraryPeepholeView.contentMode = .scaleAspectFill
        
        thumbnailRibbonView.onPhotoItemSelect = { [weak self] mediaPickerItem in
            self?.onItemSelect?(mediaPickerItem)
        }
        
        thumbnailRibbonView.onCameraItemSelect = { [weak self] in
            self?.onCameraThumbnailTap?()
        }
        
        thumbnailRibbonView.onItemMove = { [weak self] (sourceIndex, destinationIndex) in
            self?.onItemMove?(sourceIndex, destinationIndex)
        }
        
        addSubview(photoPreviewView)
        addSubview(flashView)
        addSubview(cameraControlsView)
        addSubview(photoControlsView)
        addSubview(thumbnailRibbonView)
        addSubview(photoTitleLabel)
        
        setMode(.camera)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        let cameraFrame = CGRect(
            left: bounds.left,
            right: bounds.right,
            top: bounds.top,
            height: bounds.size.width * cameraAspectRatio
        )
        
        let freeSpaceUnderCamera = bounds.bottom - cameraFrame.bottom
        let canFitExtendedControls = (freeSpaceUnderCamera >= controlsExtendedHeight)
        let controlsHeight = canFitExtendedControls ? controlsExtendedHeight : controlsCompactHeight
        
        photoPreviewView.frame = cameraFrame
        
        cameraControlsView.layout(
            left: bounds.left,
            right: bounds.right,
            bottom: bounds.bottom,
            height: controlsHeight
        )
        
        photoControlsView.frame = cameraControlsView.frame
        
        let screenIsVerySmall = (cameraControlsView.top < cameraFrame.bottom)
        
        let thumbnailRibbonAlpha: CGFloat = screenIsVerySmall ? 0.6 : 1
        let thumbnailRibbonInsets = UIEdgeInsets(
            top: 8,
            left: 8,
            bottom: 8,
            right: 8
        )
        
        let thumbnailHeightForSmallScreen = CGFloat(56)
        let bottomPanelHeight = max(height - width / 0.75, bottomPanelMinHeight)
        
        let photoRibbonHeight = screenIsVerySmall
            ? thumbnailHeightForSmallScreen + thumbnailRibbonInsets.top + thumbnailRibbonInsets.bottom
            : bottomPanelHeight - controlsHeight
        
        thumbnailRibbonView.backgroundColor = UIColor(red: 240/255, green: 240/255, blue: 240/255, alpha: thumbnailRibbonAlpha)
        thumbnailRibbonView.contentInsets = thumbnailRibbonInsets
        thumbnailRibbonView.layout(
            left: bounds.left,
            right: bounds.right,
            bottom: cameraControlsView.top,
            height: photoRibbonHeight
        )
        
        layoutPhotoTitleLabel()

        flashView.frame = cameraFrame
    }
    
    // MARK: - MediaPickerView
    
    var onShutterButtonTap: (() -> ())? {
        get { return cameraControlsView.onShutterButtonTap }
        set { cameraControlsView.onShutterButtonTap = newValue }
    }
    
    var onPhotoLibraryButtonTap: (() -> ())? {
        get { return cameraControlsView.onPhotoLibraryButtonTap }
        set { cameraControlsView.onPhotoLibraryButtonTap = newValue }
    }
    
    var onFlashToggle: ((Bool) -> ())? {
        get { return cameraControlsView.onFlashToggle }
        set { cameraControlsView.onFlashToggle = newValue }
    }
    
    var onItemSelect: ((MediaPickerItem) -> ())?
    
    var onRemoveButtonTap: (() -> ())? {
        get { return photoControlsView.onRemoveButtonTap }
        set { photoControlsView.onRemoveButtonTap = newValue }
    }
    
    var onCropButtonTap: (() -> ())? {
        get { return photoControlsView.onCropButtonTap }
        set { photoControlsView.onCropButtonTap = newValue }
    }
    
    var onCameraThumbnailTap: (() -> ())? {
        get { return photoControlsView.onCameraButtonTap }
        set { photoControlsView.onCameraButtonTap = newValue }
    }
    
    var onItemMove: ((Int, Int) -> ())?
    
    var onSwipeToItem: ((MediaPickerItem) -> ())? {
        get { return photoPreviewView.onSwipeToItem }
        set { photoPreviewView.onSwipeToItem = newValue }
    }
    
    var onSwipeToCamera: (() -> ())? {
        get { return photoPreviewView.onSwipeToCamera }
        set { photoPreviewView.onSwipeToCamera = newValue }
    }
    
    var onSwipeToCameraProgressChange: ((CGFloat) -> ())? {
        get { return photoPreviewView.onSwipeToCameraProgressChange }
        set { photoPreviewView.onSwipeToCameraProgressChange = newValue }
    }
    
    var previewSize: CGSize {
        return photoPreviewView.size
    }
    
    func setMode(_ mode: MediaPickerViewMode) {
        
        switch mode {
        
        case .camera:
            cameraControlsView.isHidden = false
            photoControlsView.isHidden = true
            
            thumbnailRibbonView.selectCameraItem()
            photoPreviewView.scrollToCamera()
        
        case .photoPreview(let photo):
            
            photoPreviewView.scrollToMediaItem(photo)
            
            cameraControlsView.isHidden = true
            photoControlsView.isHidden = false
        }
        
        self.mode = mode
        
        adjustForDeviceOrientation(deviceOrientation)
    }
    
    func setCameraControlsEnabled(_ enabled: Bool) {
        cameraControlsView.setCameraControlsEnabled(enabled)
    }
    
    func setCameraButtonVisible(_ visible: Bool) {
        photoPreviewView.setCameraVisible(visible)
        thumbnailRibbonView.setCameraItemVisible(visible)
    }
    
    func setLatestPhotoLibraryItemImage(_ image: ImageSource?) {
        cameraControlsView.setLatestPhotoLibraryItemImage(image)
    }
    
    func setFlashButtonVisible(_ visible: Bool) {
        cameraControlsView.setFlashButtonVisible(visible)
    }
    
    func setFlashButtonOn(_ isOn: Bool) {
        cameraControlsView.setFlashButtonOn(isOn)
    }
    
    func animateFlash() {
        
        flashView.alpha = 1
        
        UIView.animate(
            withDuration: 0.3,
            delay: 0,
            options: [.curveEaseOut],
            animations: { 
                self.flashView.alpha = 0
            },
            completion: nil
        )
    }
    
    var onCameraToggleButtonTap: (() -> ())? {
        get { return cameraControlsView.onCameraToggleButtonTap }
        set { cameraControlsView.onCameraToggleButtonTap = newValue }
    }
    
    func setCameraToggleButtonVisible(_ visible: Bool) {
        cameraControlsView.setCameraToggleButtonVisible(visible)
    }
    
    func setShutterButtonEnabled(_ enabled: Bool) {
        cameraControlsView.setShutterButtonEnabled(enabled)
    }
    
    func setPhotoLibraryButtonEnabled(_ enabled: Bool) {
        cameraControlsView.setPhotoLibraryButtonEnabled(enabled)
    }
    
    func addItems(_ items: [MediaPickerItem], animated: Bool, completion: @escaping () -> ()) {
        photoPreviewView.addItems(items)
        thumbnailRibbonView.addItems(items, animated: animated, completion: completion)
    }
    
    func updateItem(_ item: MediaPickerItem) {
        photoPreviewView.updateItem(item)
        thumbnailRibbonView.updateItem(item)
    }

    func removeItem(_ item: MediaPickerItem) {
        photoPreviewView.removeItem(item, animated: false)
        thumbnailRibbonView.removeItem(item, animated: true)
    }
    
    func selectItem(_ item: MediaPickerItem) {
        thumbnailRibbonView.selectMediaItem(item)
    }
    
    func moveItem(from sourceIndex: Int, to destinationIndex: Int) {
        photoPreviewView.moveItem(from: sourceIndex, to: destinationIndex)
    }
    
    func scrollToItemThumbnail(_ item: MediaPickerItem, animated: Bool) {
        thumbnailRibbonView.scrollToItemThumbnail(item, animated: animated)
    }
    
    func selectCamera() {
        thumbnailRibbonView.selectCameraItem()
    }
    
    func scrollToCameraThumbnail(animated: Bool) {
        thumbnailRibbonView.scrollToCameraThumbnail(animated: animated)
    }
    
    func adjustForDeviceOrientation(_ orientation: DeviceOrientation) {
        
        deviceOrientation = orientation
        
        var orientation = orientation
        if UIDevice.current.userInterfaceIdiom == .phone, case .photoPreview = mode {
            orientation = .portrait
        }
        
        let transform = CGAffineTransform(deviceOrientation: orientation)
                
        cameraControlsView.setControlsTransform(transform)
        photoControlsView.setControlsTransform(transform)
        thumbnailRibbonView.setControlsTransform(transform)
    }
    
    func setCameraView(_ view: UIView) {
        photoPreviewView.setCameraView(view)
    }
    
    func setCameraOutputParameters(_ parameters: CameraOutputParameters) {
        thumbnailRibbonView.setCameraOutputParameters(parameters)
    }
    
    func setCameraOutputOrientation(_ orientation: ExifOrientation) {
        thumbnailRibbonView.setCameraOutputOrientation(orientation)
    }
    
    func setPhotoTitle(_ title: String) {
        photoTitleLabel.text = title
        layoutPhotoTitleLabel()
    }
    
    func setPhotoTitleStyle(_ style: MediaPickerTitleStyle) {
        switch style {
        case .dark:
            photoTitleLabel.textColor = .black
            photoTitleLabel.layer.shadowOpacity = 0
        case .light:
            photoTitleLabel.textColor = .white
            photoTitleLabel.layer.shadowOpacity = 0.5
        }
    }
    
    func setPhotoTitleAlpha(_ alpha: CGFloat) {
        photoTitleLabel.alpha = alpha
    }
    
    func setTheme(_ theme: MediaPickerRootModuleUITheme) {

        cameraControlsView.setTheme(theme)
        photoControlsView.setTheme(theme)
        thumbnailRibbonView.setTheme(theme)
    }
    
    func setShowsCropButton(_ showsCropButton: Bool) {
        photoControlsView.setShowsCropButton(showsCropButton)
    }
    
    func reloadCamera() {
        photoPreviewView.reloadCamera()
        thumbnailRibbonView.reloadCamera()
    }
    
    // MARK: - Private
    
    private func layoutPhotoTitleLabel() {
        photoTitleLabel.sizeToFit()
        photoTitleLabel.centerX = bounds.centerX
    }
}
