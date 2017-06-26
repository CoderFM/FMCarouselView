//
//  FMCarouselView.swift
//  FMCarouselView
//
//  Created by 周发明 on 17/6/25.
//  Copyright © 2017年 周发明. All rights reserved.
//

import UIKit


@objc protocol FMCarouselViewPrortocol{
    @objc optional func taped(carouselView: FMCarouselView, index: Int) -> Void
}

extension FMCarouselViewPrortocol{
    func layout(_ itemSize: CGSize) -> UICollectionViewLayout{
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.itemSize = itemSize
        flowLayout.minimumLineSpacing = 0
        flowLayout.minimumInteritemSpacing = 0
        flowLayout.scrollDirection = .horizontal
        return flowLayout
    }
    
    func configurationCell(cell: UICollectionViewCell, indexPath: IndexPath, item: Any) {
        guard let customCell = cell as? FMCarouselViewCell else {
            return
        }
        customCell.subView.item = item
        customCell.subView.isUserInteractionEnabled = false
    }
    
    func unlimitedCycleFunc(_ currentIndex: inout Int, currentView: inout FMCarouselSubView, reuseView: inout FMCarouselSubView, scrollView: UIScrollView, totalCount: Int, configutationBlock: (FMCarouselSubView, Int) -> Void) -> Void {
        
        if (scrollView.contentSize.width <= scrollView.bounds.size.width * 1.5) {
            return
        }
        
        let width = scrollView.bounds.size.width
        
        var index = currentIndex
        
        if (scrollView.contentOffset.x < width) {
            index -= 1
            if index < 0 {
                index = totalCount - 1
            }
        } else if (scrollView.contentOffset.x > width) {
            index += 1
            if (index > totalCount - 1){
                index = 0
            }
        }
        
        configutationBlock(reuseView, index)
        
        if scrollView.contentOffset.x == 0 || scrollView.contentOffset.x == width * 2{
            
            let temp = reuseView.frame
            reuseView.frame = currentView.frame
            currentView.frame = temp
            
            let tepmView = reuseView
            reuseView = currentView
            currentView = tepmView
            
            currentIndex = index
            scrollView.contentOffset = CGPoint(x: width, y: 0)
        }
    }
}

protocol FMCarouselSubViewPrortocol{
    func configurationImageView(imageView: UIImageView, url: String) -> Void
}

class FMCarouselView: UIView {
    
    var delegate: FMCarouselViewPrortocol? = nil
    
    var cellClass: AnyClass? = nil
    
    var unlimitedCycle: Bool = false
    
    var currentIndex: Int = 0
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.cellClass = FMCarouselViewCell.self
        self.backgroundColor = UIColor.white
    }
    
    convenience init(frame: CGRect, anyClass: AnyClass?) {
        self.init(frame: frame)
        self.cellClass = anyClass
    }
    
    convenience init(frame: CGRect, unlimitedCycle: Bool) {
        self.init(frame: frame)
        self.unlimitedCycle = unlimitedCycle
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func reloadItems() -> Void {
        if self.unlimitedCycle {
            if self.items.count > 1 {
                self.scrollView.contentSize = CGSize(width: self.bounds.size.width * 3, height: self.bounds.size.height)
                self.scrollView.contentOffset = CGPoint(x: self.bounds.size.width, y: 0)
                self.currentView.frame = CGRect(origin: CGPoint(x: self.bounds.size.width, y: 0), size: self.bounds.size)
            } else {
                self.scrollView.contentSize = CGSize(width: self.bounds.size.width, height: self.bounds.size.height)
                self.scrollView.contentOffset = CGPoint(x: 0, y: 0)
                self.currentView.frame = CGRect(origin: CGPoint(x: 0, y: 0), size: self.bounds.size)
            }
            self.currentView.item = ((self.items.count > 0) ? self.items[0] : nil)
        } else {
            self.collectionView.reloadData()
        }
    }
    
    var items: [Any] = []{
        didSet{
            self.reloadItems()
        }
    }
    
    fileprivate lazy var collectionView: UICollectionView = {
        var layout: UICollectionViewLayout
        if self.delegate?.layout(self.bounds.size) != nil {
            layout = self.delegate!.layout(self.bounds.size)
        } else {
            layout = UICollectionViewFlowLayout()
            let flowLayout = layout as! UICollectionViewFlowLayout
            flowLayout.itemSize = self.bounds.size
            flowLayout.minimumLineSpacing = 0
            flowLayout.minimumInteritemSpacing = 0
        }
        let collectionView = UICollectionView(frame: CGRect(), collectionViewLayout: layout)
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.backgroundColor = UIColor.clear
        collectionView.isPagingEnabled = true
        collectionView.register(self.cellClass, forCellWithReuseIdentifier: self.cellClass!.identifier)
        
        self.addSubview(collectionView)
        return collectionView
    }()
    
    fileprivate lazy var scrollView: UIScrollView = {
        let scroll = UIScrollView()
        scroll.delegate = self
        scroll.isPagingEnabled = true
        scroll.backgroundColor = UIColor.clear
        self.addSubview(scroll)
        return scroll
    }()
    
    fileprivate lazy var reuseView: FMCarouselSubView = {
        let imageView = FMCarouselSubView()
        self.scrollView.addSubview(imageView)
        imageView.tapBlock = {
            () in
            self.taped()
        }
        return imageView
    }()
    
    fileprivate lazy var currentView: FMCarouselSubView = {
        let imageView = FMCarouselSubView()
        self.scrollView.addSubview(imageView)
        imageView.tapBlock = {
            () in
            self.taped()
        }
        return imageView
    }()
    
    override func layoutSubviews() {
        super.layoutSubviews()
        if self.unlimitedCycle {
            self.scrollView.frame = self.bounds
        } else {
            self.collectionView.frame = self.bounds
        }
    }
    
    func taped() -> Void {
        if self.unlimitedCycle {
            self.delegate?.taped?(carouselView: self, index: self.currentIndex)
        } else {
            let index = self.collectionView.contentOffset.x / self.bounds.size.width
            self.delegate?.taped?(carouselView: self, index: Int(index))
        }
    }
}

extension FMCarouselView: UICollectionViewDelegate{
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if self.unlimitedCycle {
            self.delegate?.unlimitedCycleFunc(&self.currentIndex, currentView: &self.currentView, reuseView: &self.reuseView, scrollView: scrollView, totalCount: self.items.count, configutationBlock: { (subView, index) in
                subView.item = self.items[index]
            })
        }
    }
}

extension FMCarouselView: UICollectionViewDataSource{
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.items.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: self.cellClass!.identifier, for: indexPath)
        if indexPath.row < self.items.count {
            self.delegate?.configurationCell(cell: cell, indexPath: indexPath, item: self.items[indexPath.row])
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        self.delegate?.taped?(carouselView: self, index: indexPath.row)
    }
}

extension UICollectionViewCell{
    static var identifier: String {
        get {
            return "\(self)"
        }
    }
}


class FMCarouselSubView: UIView {
    
    var delegate: FMCarouselSubViewPrortocol? = nil
    
    var tapBlock: () -> () = { () in }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.delegate = self
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    var item: Any? = nil{
        willSet(newValue){
            if newValue == nil {
                self.imageView.image = nil
                self.label.text = "没有图片!"
            }
            
            if ((newValue as? UIImage) != nil) {
                self.imageView.image = newValue as! UIImage?
                self.label.text = nil
            }
            guard let string = newValue as? String else {
                return
            }
            if string.hasPrefix("http://") || string.hasPrefix("https://") {
                self.label.text = nil
                self.delegate?.configurationImageView(imageView: self.imageView, url: string)
            } else {
                self.label.text = string
                self.imageView.image = nil
            }
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.imageView.frame = self.bounds
        self.label.frame = self.bounds
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.tapBlock()
    }
    
    lazy var label: UILabel = {
        let label = UILabel()
        label.textAlignment = NSTextAlignment.center
        label.numberOfLines = 0
        self.addSubview(label)
        return label
    }()
    
    lazy var imageView: UIImageView = {
        let imageView = UIImageView()
        self.addSubview(imageView)
        return imageView
    }()
}

extension FMCarouselSubView: FMCarouselSubViewPrortocol{
    func configurationImageView(imageView: UIImageView, url: String) -> Void {
        imageView.fm_loadImage(url: URL(string: url)!)
    }
}

class FMCarouselViewCell: UICollectionViewCell {
    
    var delegate: FMCarouselSubViewPrortocol? = nil {
        willSet {
            self.subView.delegate = newValue
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.subView.frame = self.bounds
    }
    
    lazy var subView: FMCarouselSubView = {
        let view = FMCarouselSubView()
        self.addSubview(view)
        return view
    }()
}

