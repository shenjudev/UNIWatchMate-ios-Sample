//
//  PhotoLibraryController.swift
//  LensMoo
//
//  Created by abel on 2025/5/6.
//  Copyright © 2025 LensMoo. All rights reserved.
//

import RxSwift


class PhotoLibraryController: UIViewController {
    public var disposeBag = DisposeBag()

    lazy var viewModel = PhotoLibraryViewModel(vc: self)
    //    let receiveImgView = UIImageView(image: image:UIImage(named: "ic_logo_28))
    let photoLibraryHeader = PhotoLibraryHeader()
    let photoLibraryOperationView = PhotoLibraryOperationView()

    let emptyView = UIView()
    let emptyContentView = UIView()
    let helpImageView = UIImageView(image:UIImage(named: "ic_nodata_136"))
    let emptyLb = UILabel().tt_text("暂无照片").tt_textColor(.white).tt_font(.pingFangSC_Regular(14))
    let helpLb = UILabel().tt_text("快使用眼镜拍照吧").tt_textColor(.hex("#777777"))
        .tt_font(.pingFangSC_Regular(14)).tt_numberOfLines(0).tt_textAlignment(
            .center)

    private lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.minimumInteritemSpacing = 1
        layout.minimumLineSpacing = 1
        layout.sectionInset = UIEdgeInsets(
            top: 1, left: 0, bottom: 10, right: 0)
        let collection = UICollectionView(
            frame: .zero, collectionViewLayout: layout)
        collection.backgroundColor = .clear
        collection.showsVerticalScrollIndicator = false
        collection.delegate = self
        collection.dataSource = self
        collection.allowsMultipleSelection = true
        collection.register(
            PhotoCell.self, forCellWithReuseIdentifier: "PhotoCell")
        collection.register(
            DateHeaderView.self,
            forSupplementaryViewOfKind: UICollectionView
                .elementKindSectionHeader,
            withReuseIdentifier: "DateHeader")
        return collection
    }()

    private let bottomOperationView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.isHidden = true  // 初始时隐藏
        return view
    }()

    private let downloadButton: UIButton = {
        let button = UIButton(type: .system)
        button.tintColor = .black
        button.imageEdgeInsets =  UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 8)
        return button
    }()

    private let selectedCountLabel: UILabel = {
        let label = UILabel()
        label.textColor = .black
        label.font = .systemFont(ofSize: 16)
        label.textAlignment = .center
        return label
    }()

    private let deleteButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(named: "ic_trash_black_28"), for: .normal)
        button.imageEdgeInsets =  UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 8)
        return button
    }()

    private var selectedIndexPaths: Set<IndexPath> = []
    private var photoGroups: [(date: Date, urls: [URL])] = []

    // 添加标题引用属性
    private weak var previewTitleLabel: UILabel?
    private weak var previewTimeLabel: UILabel?

    override func viewDidLoad() {
        appendUI()
        layoutUI()
        actionsHandler()
    }

     func appendUI() {
        view.backgroundColor = .black
        view.addSubview(emptyView)
        emptyView.addSubview(emptyContentView)
        emptyContentView.addSubview(helpImageView)
        emptyContentView.addSubview(emptyLb)
        emptyContentView.addSubview(helpLb)
        view.addSubview(photoLibraryHeader)
        view.addSubview(photoLibraryOperationView)
        view.addSubview(collectionView)

        // 添加底部操作栏
        view.addSubview(bottomOperationView)
        bottomOperationView.addSubview(downloadButton)
        bottomOperationView.addSubview(selectedCountLabel)
        bottomOperationView.addSubview(deleteButton)
    }

     func layoutUI() {
       
        photoLibraryHeader.snp.makeConstraints { make in
            make.top.leading.trailing.equalToSuperview()
        }
        
        photoLibraryOperationView.setContentCompressionResistancePriority(.required, for: .vertical)

        photoLibraryOperationView.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview()
            make.top.equalTo(photoLibraryHeader.snp.bottom)
        }
        emptyView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        emptyContentView.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.centerX.equalToSuperview()
            make.width.equalToSuperview()
        }
        helpImageView.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.centerX.equalToSuperview()
        }
        emptyLb.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(helpImageView.snp.bottom).offset(20)
        }
        helpLb.snp.makeConstraints { make in
            make.top.equalTo(emptyLb.snp.bottom).offset(10)
            make.centerX.equalTo(emptyLb)
            make.width.lessThanOrEqualTo(kSCREEN_WIDTH - 40)
            make.bottom.equalToSuperview()
        }
        //        receiveImgView.snp.makeConstraints { make in
        //            make.center.equalToSuperview()
        //            make.width.height.equalTo(160)
        //        }
        collectionView.snp.makeConstraints { make in
            make.top.equalTo(photoLibraryOperationView.snp.bottom)
            make.left.right.equalToSuperview()
            make.bottom.equalTo(view.safeAreaLayoutGuide)
        }

        // 底部操作栏布局
        bottomOperationView.snp.makeConstraints { make in
            make.left.right.equalToSuperview()
            make.bottom.equalTo(view.safeAreaLayoutGuide)
            make.height.equalTo(44)
        }

        downloadButton.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(12)
            make.centerY.equalToSuperview()
            make.width.height.equalTo(44)
        }

        selectedCountLabel.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }

        deleteButton.snp.makeConstraints { make in
            make.right.equalToSuperview().offset(-12)
            make.centerY.equalToSuperview()
            make.width.height.equalTo(44)
        }
    }
    
    override func viewDidLayoutSubviews() {
      
    }
    
    private func updateCollectionViewConstraints() {
        collectionView.snp.remakeConstraints { make in
            // 如果 operationView 隐藏了，就直接贴着 header
            if photoLibraryOperationView.isHidden {
                make.top.equalTo(photoLibraryHeader.snp.bottom)
            } else {
                make.top.equalTo(photoLibraryOperationView.snp.bottom)
            }
            make.left.right.equalToSuperview()
            // 根据bottomOperationView的可见性调整底部约束
            if !bottomOperationView.isHidden {
                make.bottom.equalTo(bottomOperationView.snp.top)
            } else {
                make.bottom.equalTo(view.safeAreaLayoutGuide)
            }
        }
        
        // 使用动画更新布局
        UIView.animate(withDuration: 0.1) {
            self.view.layoutIfNeeded()
        }
    }

     func actionsHandler() {
     
        
        viewModel.photoCount.bind { [weak self] rs in
            guard let self = self else { return }
            DDLogInfo("photoCount result = \(rs)")
            let receivedImgCount = viewModel.phoneImgUrlFromDevice.value.count
            var newPhotoCount = rs - receivedImgCount
            if newPhotoCount <= 0 {
                newPhotoCount = 0
            }
            photoLibraryOperationView.isHidden = false

            updateCollectionViewConstraints()
        }.disposed(by: disposeBag)
        
        viewModel.deviceFileNameList.bind { [weak self] rs in
            guard let self = self else { return }
            //修正数量
            let totalPhotoCount = rs.count
//            photoLibraryOperationView.titleLb.text = "\(totalPhotoCount)张新照片"
            photoLibraryOperationView.showImporting(viewModel.importingPhoto.value)

            photoLibraryOperationView.importLb.text = String(format: "导入中 (%d/%d)...", viewModel.importingIndex.value, totalPhotoCount)
            
            DDLogInfo("需要传输图片 :\(rs)")
        }.disposed(by: disposeBag)
        
        viewModel.importingIndex.bind{[weak self] rs in
            guard let self = self else { return }
            
            photoLibraryOperationView.importLb.text = String(format: "导入中 (%d/%d)...", rs, viewModel.deviceFileNameList.value.count)
        }.disposed(by: disposeBag)

        viewModel.importingPhoto.bind { [weak self] rs in
            guard let self = self else { return }
            if(!rs){
                photoLibraryOperationView.showImporting(rs)
            }

            if rs {
                photoLibraryOperationView.importLb.text = String(format: "导入中 (%d/%d)...", viewModel.importingIndex.value, viewModel.deviceFileNameList.value.count)
            }else{
                
            }
            
        }.disposed(by: disposeBag)


        viewModel.phoneImgUrlFromDevice.bind { [weak self] urls in
            guard let self = self else { return }
            photoLibraryHeader.selectModeBtn.isHidden = urls.isEmpty

            self.updatePhotoGroups(with: urls)
        }.disposed(by: disposeBag)

        photoLibraryOperationView.isUserInteractionEnabled = true
        //
        photoLibraryOperationView.importBtn.rx.tap.bind { [weak self] in
            DDLogInfo("importBtn tap")
            guard let self = self else { return }
            if viewModel.importingPhoto.value {
                viewModel.stopImport(manualOperation:true)
            } else {
                cancelSelectMode()
                viewModel.startImport()
            }
        }.disposed(by: self.disposeBag)

        deleteButton.addTarget(
            self, action: #selector(deleteTapped), for: .touchUpInside)
        downloadButton.addTarget(
            self, action: #selector(downloadTapped), for: .touchUpInside)

        photoLibraryHeader.isUserInteractionEnabled = true
        photoLibraryHeader.backBtn.rx.tap.bind { [weak self] in
             self?.navigationController?.popViewController()
        }.disposed(by: self.disposeBag)

        photoLibraryHeader.selectModeBtn.addTarget(
            self, action: #selector(selectModeBtnTapped), for: .touchUpInside)
         
        let isNoStorageDevice = WatchManager.sharedInstance().currentValue.infoModel.glassesFeatureSetModel?.feature_mask.isFeatureEnabled(.featureNoStorageDevice) ?? false
        
         photoLibraryHeader.isHidden = isNoStorageDevice
    }
    
    override func viewWillAppear(_ animated: Bool) {
        if self.viewModel.phoneImgUrlFromDevice.value.isEmpty{
            SJHud.showLoading(text: nil)
            viewModel.getDeviceImageURLs().subscribe { rs in
                SJHud.dismiss()
                DDLogInfo("getDeviceImageURLs count = \(rs.count)")
            } onError: { error in
                SJHud.dismiss()
                DDLogError("error \(error.localizedDescription )")
            }.disposed(by: self.disposeBag)
        }
        
        //切换页面时，取消选中状态
        self.navigationController?.setNavigationBarHidden(true, animated: false)
    }

    private func updatePhotoGroups(with urls: [URL]) {
        // 保存当前选中的URL
        var selectedURLs: [URL] = []
        if !selectedIndexPaths.isEmpty {
            for indexPath in selectedIndexPaths {
                if indexPath.section < photoGroups.count && indexPath.item < photoGroups[indexPath.section].urls.count {
                    selectedURLs.append(photoGroups[indexPath.section].urls[indexPath.item])
                }
            }
        }
        
        let groupedPhotos = Dictionary(grouping: urls) { url in
            let attr = try? FileManager.default.attributesOfItem(
                atPath: url.path)
            // 尝试从文件名获取日期
            let fileName = url.lastPathComponent
            // 匹配 xxxx-yymmdd-HHMMSS 格式
            if fileName.contains("-") {
                let components = fileName.components(separatedBy: "-")
                if components.count >= 3 {
                    let dateFormatter = DateFormatter()
                    dateFormatter.timeZone = TimeZone(secondsFromGMT: 0)
                    dateFormatter.dateFormat = "yyMMdd-HHmmss"
                    let dateTimeString = components[1] + "-" + components[2].components(separatedBy: ".").first!
                    if let fileDate = dateFormatter.date(from: dateTimeString) {
                        // 检查年份是否合法,避免出现12100年这样的异常情况
                        var calendar = Calendar.current
                        calendar.timeZone = TimeZone(secondsFromGMT: 0)!
                        let year = calendar.component(.year, from: fileDate)
                        if year > 2100 {
                            return Calendar.current.startOfDay(for: Date())
                        }
                        return calendar.startOfDay(for: fileDate)
                    }
                }
            } else {
                // 去掉文件扩展名后尝试解析时间戳
                let nameWithoutExtension = (fileName as NSString).deletingPathExtension
                if let timestamp = Double(nameWithoutExtension) {
                    let fileDate = Date(timeIntervalSince1970: timestamp)
                    return Calendar.current.startOfDay(for: fileDate)
                }
            }
            let date = attr?[.creationDate] as? Date ?? Date()
            return Calendar.current.startOfDay(for: date)
        }

        // 对每个分组内的urls按时间排序
        let sortedGroupedPhotos = groupedPhotos.mapValues { urls in
            return urls.sorted { url1, url2 in
                let fileName1 = url1.lastPathComponent
                let fileName2 = url2.lastPathComponent
                
                // 获取第一个URL的时间
                let time1: Date = {
                    if fileName1.contains("-") {
                        let components = fileName1.components(separatedBy: "-")
                        if components.count >= 3 {
                            let dateFormatter = DateFormatter()
                            dateFormatter.timeZone = TimeZone(secondsFromGMT: 0)
                            dateFormatter.dateFormat = "yyMMdd-HHmmss"
                            let dateTimeString = components[1] + "-" + components[2].components(separatedBy: ".").first!
                            if let fileDate = dateFormatter.date(from: dateTimeString) {
                                return fileDate
                            }
                        }
                    } else {
                        // 去掉文件扩展名后尝试解析时间戳
                        let nameWithoutExtension = (fileName1 as NSString).deletingPathExtension
                        if let timestamp = Double(nameWithoutExtension) {
                            return Date(timeIntervalSince1970: timestamp)
                        }
                    }
                    let attr = try? FileManager.default.attributesOfItem(atPath: url1.path)
                    return attr?[.creationDate] as? Date ?? Date()
                }()
                
                // 获取第二个URL的时间
                let time2: Date = {
                    if fileName2.contains("-") {
                        let components = fileName2.components(separatedBy: "-")
                        if components.count >= 3 {
                            let dateFormatter = DateFormatter()
                            dateFormatter.timeZone = TimeZone(secondsFromGMT: 0)
                            dateFormatter.dateFormat = "yyMMdd-HHmmss"
                            let dateTimeString = components[1] + "-" + components[2].components(separatedBy: ".").first!
                            if let fileDate = dateFormatter.date(from: dateTimeString) {
                                return fileDate
                            }
                        }
                    } else {
                        // 去掉文件扩展名后尝试解析时间戳
                        let nameWithoutExtension = (fileName2 as NSString).deletingPathExtension
                        if let timestamp = Double(nameWithoutExtension) {
                            return Date(timeIntervalSince1970: timestamp)
                        }
                    }
                    let attr = try? FileManager.default.attributesOfItem(atPath: url2.path)
                    return attr?[.creationDate] as? Date ?? Date()
                }()
                
                return time1 > time2 
            }
        }

        photoGroups = sortedGroupedPhotos.map { (date: $0.key, urls: $0.value) }
            .sorted { $0.date > $1.date }

        collectionView.reloadData()
        
        // 恢复选中状态
        if !selectedURLs.isEmpty && photoLibraryHeader.selectModeBtn.isSelected {
            selectedIndexPaths.removeAll()
            
            // 找到之前选中的URL对应的新IndexPath并重新选中
            for (sectionIndex, group) in photoGroups.enumerated() {
                for (itemIndex, url) in group.urls.enumerated() {
                    if selectedURLs.contains(url) {
                        let indexPath = IndexPath(item: itemIndex, section: sectionIndex)
                        selectedIndexPaths.insert(indexPath)
                        collectionView.selectItem(at: indexPath, animated: false, scrollPosition: .centeredHorizontally)
                    }
                }
            }
            
            // 更新底部操作栏状态
            updateDeleteButtonVisibility()
        }
        
        updateEmptyViewVisibility()
    }

    private func updateEmptyViewVisibility() {
        emptyView.isHidden = !photoGroups.isEmpty
    }

    @objc private func deleteTapped() {
        guard !selectedIndexPaths.isEmpty else { return }

        let alert = UIAlertController(
            title: "确认删除",
            message: "确定要删除选中的\(selectedIndexPaths.count)张照片吗？",
            preferredStyle: .alert
        )

        alert.addAction(UIAlertAction(title: "取消", style: .cancel))
        alert.addAction(
            UIAlertAction(title: "删除", style: .destructive) { [weak self] _ in
                self?.deleteSelectedPhotos()
            })
        alert.show()

        
    }


    private func deleteSelectedPhotos() {
      
        var deletedIndexPaths: [IndexPath] = []
        var deletedPhotoNames: [String] = []

        for indexPath in selectedIndexPaths.sorted(by: >) {
            let url = photoGroups[indexPath.section].urls[indexPath.item]
            let fileName = url.lastPathComponent
            
            deletedPhotoNames.append(fileName)
        }
        for indexPath in selectedIndexPaths.sorted(by: >) {
            let url = photoGroups[indexPath.section].urls[
                indexPath.item]
            let fileName = url.lastPathComponent
            if viewModel.deleteDeviceImage(fileName: fileName) {
                photoGroups[indexPath.section].urls.remove(
                    at: indexPath.item)
                deletedIndexPaths.append(indexPath)
            }
        }

        let emptySections = photoGroups.enumerated()
            .filter { $0.element.urls.isEmpty }
            .map { $0.offset }
            .sorted(by: >)

        emptySections.forEach { section in
            self.photoGroups.remove(at: section)
        }

        selectedIndexPaths.removeAll()

        collectionView.performBatchUpdates {
            self.collectionView.deleteItems(at: deletedIndexPaths)
            self.collectionView.deleteSections(IndexSet(emptySections))
        }
        SJHud.showLoading(text: nil)
        updateDeleteButtonVisibility()
        updateEmptyViewVisibility()
        viewModel.letDeviceDeletePhoto(names: deletedPhotoNames) {
            [weak self] rs in
            SJHud.dismiss()
            guard let self = self else {
                return
            }
            if !rs {
              //记录进待删除列表
            }
        }
    }
    
    private func deletePhotos( toDeleteIndexPaths: Set<IndexPath>?,callBack:CommonBoolBlock?) {
      
        if viewModel.importingPhoto.value {
            DDLogInfo("importing_dot")
            return
        }
        guard  toDeleteIndexPaths != nil else {return}
        var deletedIndexPaths: [IndexPath] = []
        var deletedPhotoNames: [String] = []

        for indexPath in toDeleteIndexPaths!.sorted(by: >) {
            let url = photoGroups[indexPath.section].urls[indexPath.item]
            let fileName = url.lastPathComponent
            deletedPhotoNames.append(fileName)
        }
        SJHud.showLoading(text: nil)
        var failDeleteCount = 0
        for indexPath in toDeleteIndexPaths!.sorted(by: >) {
            let url = photoGroups[indexPath.section].urls[
                indexPath.item]
            let fileName = url.lastPathComponent
            if viewModel.deleteDeviceImage(fileName: fileName) {
                photoGroups[indexPath.section].urls.remove(
                    at: indexPath.item)
                deletedIndexPaths.append(indexPath)
            }else{
                DDLogInfo("删除失败 \(fileName)")
                failDeleteCount += 1
            }
        }
        if failDeleteCount > 0 {
            callBack?(false)
            return
        }

        let emptySections = photoGroups.enumerated()
            .filter { $0.element.urls.isEmpty }
            .map { $0.offset }
            .sorted(by: >)

        emptySections.forEach { section in
            self.photoGroups.remove(at: section)
        }

        collectionView.performBatchUpdates {
            self.collectionView.deleteItems(at: deletedIndexPaths)
            self.collectionView.deleteSections(IndexSet(emptySections))
        }

        updateDeleteButtonVisibility()
        updateEmptyViewVisibility()
        callBack?(true)
        viewModel.letDeviceDeletePhoto(names: deletedPhotoNames) {
            [weak self] rs in
            SJHud.dismiss()
            guard let self = self else {
                return
            }
            if !rs {
            }
        }
    }

    private func updateDeleteButtonVisibility() {
        let shouldShow = !selectedIndexPaths.isEmpty
        UIView.animate(withDuration: 0.1) {
            self.bottomOperationView.isHidden = shouldShow ? false : true
            self.selectedCountLabel.text = String(format: "已选 %d/%d 项", self.selectedIndexPaths.count,self.viewModel.phoneImgUrlFromDevice.value.count)
            // 更新collectionView的约束
            self.updateCollectionViewConstraints()
        }
    }

    fileprivate func cancelSelectMode() {
        photoLibraryHeader.selectModeBtn.isSelected = false
        selectedIndexPaths.removeAll()
        updateDeleteButtonVisibility()
        collectionView.allowsMultipleSelection = false
        for indexPath in collectionView.indexPathsForSelectedItems ?? [] {
            collectionView.deselectItem(at: indexPath, animated: true)
        }
    }
    
    @objc private func selectModeBtnTapped() {
        if photoLibraryHeader.selectModeBtn.isSelected {
            cancelSelectMode()
        } else {
            if viewModel.importingPhoto.value {
                DDLogInfo("导入中...")
                return
            }
            photoLibraryHeader.selectModeBtn.isSelected = true
            collectionView.allowsMultipleSelection = true
        }
    }

    @objc private func downloadTapped() {
        if viewModel.importingPhoto.value {
            SJHud.showText(status: "导入中...")
        return
        }
        guard !selectedIndexPaths.isEmpty else { return }

        var selectedPhotos: [URL] = []
        for indexPath in selectedIndexPaths {
            let url = photoGroups[indexPath.section].urls[indexPath.item]
            selectedPhotos.append(url)
        }
        viewModel.save2SystemAlbum(fileUrls: selectedPhotos)
        
    }

    private func getDateFromURL(_ url: URL) -> Date {
        let fileName = url.lastPathComponent
        // 匹配 xxxx-yymmdd-HHMMSS 格式
        if fileName.contains("-") {
            let components = fileName.components(separatedBy: "-")
            if components.count >= 3 {
                let dateFormatter = DateFormatter()
                dateFormatter.timeZone = TimeZone(secondsFromGMT: 0)
                dateFormatter.dateFormat = "yyMMdd-HHmmss"
                let dateTimeString = components[1] + "-" + components[2].components(separatedBy: ".").first!
                if let fileDate = dateFormatter.date(from: dateTimeString) {
                    // 检查年份是否合法,避免出现12100年这样的异常情况
                    var calendar = Calendar.current
                    calendar.timeZone = TimeZone(secondsFromGMT: 0)!
                    let year = calendar.component(.year, from: fileDate)
                    if year > 2100 {
                        return Calendar.current.startOfDay(for: Date())
                    }
                    return fileDate
                }
            }
        } else {
            // 去掉文件扩展名后尝试解析时间戳
            let nameWithoutExtension = (fileName as NSString).deletingPathExtension
            if let timestamp = Double(nameWithoutExtension) {
                return Date(timeIntervalSince1970: timestamp)
            }
        }
        // 如果都不匹配，则使用文件属性中的创建时间
        let attr = try? FileManager.default.attributesOfItem(atPath: url.path)
        return attr?[.creationDate] as? Date ?? Date()
    }

    private func formatDateForDisplay( photoDate: Date) -> (title: String, time: String) {
        let formatter = DateFormatter()
        formatter.timeZone = TimeZone(secondsFromGMT: 0)
        let appLocale: Locale
        if let preferredLanguage = Bundle.main.preferredLocalizations.first {
            appLocale = Locale(identifier: preferredLanguage)
        } else {
            appLocale = .current // 如果无法获取首选本地化，回退到系统Locale
        }
        formatter.dateFormat = "yyyyMMMd"
        formatter.dateStyle = .long
        formatter.locale = appLocale
        let title = formatter.string(from: photoDate)
        
        formatter.dateFormat = "HH:mm"
        let time = formatter.string(from: photoDate)
        
        return (title, time)
    }
    
    func refreshDateTime(index: Int){
        // 如果标题被禁用，直接返回
        guard let titleLabel = previewTitleLabel,
              let timeLabel = previewTimeLabel else {
            return
        }
        
        // 计算当前图片所属的组和日期
        var currentIndex = 0
        for (_, group) in photoGroups.enumerated() {
            if index < currentIndex + group.urls.count {
                let itemIndex = index - currentIndex
                let url = group.urls[itemIndex]
                // 避免在主线程进行耗时计算
                DispatchQueue.global(qos: .userInteractive).async { [weak self] in
                    guard let self = self else { return }
                    let photoDate = self.getDateFromURL(url)
                    let dateInfo = self.formatDateForDisplay(photoDate: photoDate)
                    
                    // 使用预先保存的引用更新UI
                    DispatchQueue.main.asyncAfter(deadline: .now()) {
                        // 添加动画使过渡更平滑
                        titleLabel.text = dateInfo.title
                        timeLabel.text = dateInfo.time
                    }
                }
                break
            }
            currentIndex += group.urls.count
        }
        
        
        // 处理滚动到新索引的情况
        var currentIndex2 = 0
        for (section, group) in photoGroups.enumerated() {
            let nextIndex = currentIndex2 + group.urls.count
            if index < nextIndex {
                let item = index - currentIndex
                let indexPath = IndexPath(item: item, section: section)
                // 确保 cell 可见
                collectionView.scrollToItem(at: indexPath, at: .centeredVertically, animated: false)
                break
            }
            currentIndex2 = nextIndex
        }
    }

    func willDismissAtPageIndex(_ index: Int) {
        // 在消失时更新 collection view 的状态
        var currentIndex = 0
        for (section, group) in photoGroups.enumerated() {
            let nextIndex = currentIndex + group.urls.count
            if index < nextIndex {
                let item = index - currentIndex
                let indexPath = IndexPath(item: item, section: section)
                // 确保 cell 可见
                collectionView.scrollToItem(at: indexPath, at: .centeredVertically, animated: false)
                break
            }
            currentIndex = nextIndex
        }
    }

    
}

// MARK: - UICollectionViewDataSource & UICollectionViewDelegate
extension PhotoLibraryController: UICollectionViewDataSource,
    UICollectionViewDelegate
{
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return photoGroups.count
    }

    func collectionView(
        _ collectionView: UICollectionView, numberOfItemsInSection section: Int
    ) -> Int {
        return photoGroups[section].urls.count
    }

    func collectionView(
        _ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath
    ) -> UICollectionViewCell {
        let cell =
            collectionView.dequeueReusableCell(
                withReuseIdentifier: "PhotoCell", for: indexPath) as! PhotoCell
        let url = photoGroups[indexPath.section].urls[indexPath.item]
        cell.configure(with: url)
        return cell
    }

    func collectionView(
        _ collectionView: UICollectionView,
        viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath
    ) -> UICollectionReusableView {
        if kind == UICollectionView.elementKindSectionHeader {
            let header =
                collectionView.dequeueReusableSupplementaryView(
                    ofKind: kind, withReuseIdentifier: "DateHeader",
                    for: indexPath) as! DateHeaderView
            header.configure(with: photoGroups[indexPath.section].date)
            return header
        }
        return UICollectionReusableView()
    }

    func collectionView(
        _ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath
    ) {
        if photoLibraryHeader.selectModeBtn.isSelected {
            selectedIndexPaths.insert(indexPath)
            updateDeleteButtonVisibility()
        } else {
            collectionView.deselectItem(at: indexPath, animated: false)
            let url = photoGroups[indexPath.section].urls[indexPath.item]
            let cell = collectionView.cellForItem(at: indexPath) as! PhotoCell
            let originImage = cell.imageView // some image for baseImage
        }
    }

    func collectionView(
        _ collectionView: UICollectionView,
        didDeselectItemAt indexPath: IndexPath
    ) {
        if photoLibraryHeader.selectModeBtn.isSelected {
            selectedIndexPaths.remove(indexPath)
            updateDeleteButtonVisibility()
        }
    }
}

// MARK: - UICollectionViewDelegateFlowLayout
extension PhotoLibraryController: UICollectionViewDelegateFlowLayout {
    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        sizeForItemAt indexPath: IndexPath
    ) -> CGSize {
        let spacing: CGFloat = 2  // 图片间距
        let numberOfItemsPerRow: CGFloat = 3  // 每行3个
        let totalSpacing = spacing * (numberOfItemsPerRow - 1)  // 总间距

        let width =
            (collectionView.bounds.width - totalSpacing) / numberOfItemsPerRow
        return CGSize(width: width, height: width)  // 保持正方形
    }

    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        referenceSizeForHeaderInSection section: Int
    ) -> CGSize {
        return CGSize(width: collectionView.bounds.width, height: 40)
    }
}

class PhotoCell: UICollectionViewCell {
    let imageView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFill
        iv.clipsToBounds = true
        return iv
    }()

    private let checkmarkView: UIImageView = {
        let iv = UIImageView()
        iv.image = UIImage(named: "ic_check_green_34")
        iv.tintColor = .white
        iv.isHidden = true
        return iv
    }()

    override var isSelected: Bool {
        didSet {
            checkmarkView.isHidden = !isSelected
            updateSelectedState()
        }
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupUI() {
        contentView.addSubview(imageView)
        contentView.addSubview(checkmarkView)

        imageView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        checkmarkView.snp.makeConstraints { make in
            make.bottom.right.equalToSuperview()
            make.width.height.equalTo(34)
        }
    }

    func configure(with url: URL) {
        imageView.image = UIImage(contentsOfFile: url.path)
    }

    private func updateSelectedState() {
        UIView.animate(withDuration: 0.2) {
            self.contentView.alpha = self.isSelected ? 1.0 : 1.0
        }
    }
}

class DateHeaderView: UICollectionReusableView {
    private let dateLabel: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.font = .systemFont(ofSize: 15, weight: .medium)
        return label
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupUI() {
        backgroundColor = .clear
        addSubview(dateLabel)
        dateLabel.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(16)
            make.centerY.equalToSuperview()
        }
    }

    func configure(with date: Date) {
        let formatter = DateFormatter()
        let calendar = Calendar.current
        let today = Date()
        let appLocale: Locale
        if let preferredLanguage = Bundle.main.preferredLocalizations.first {
            appLocale = Locale(identifier: preferredLanguage)
        } else {
            appLocale = .current // 如果无法获取首选本地化，回退到系统Locale
        }
        formatter.locale = appLocale
        if calendar.isDateInToday(date) {
            dateLabel.text = "今天"
        } else if calendar.component(.year, from: date)
            == calendar.component(.year, from: today)
        {
            formatter.dateFormat = "MMMd"
            dateLabel.text = formatter.string(from: date)
        } else {
            formatter.dateFormat = "yyyyMMMd"
            formatter.dateStyle = .long
            dateLabel.text = formatter.string(from: date)
        }
    }
}


