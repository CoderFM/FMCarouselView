//
//  ViewController.swift
//  FMCarouselView
//
//  Created by 周发明 on 17/6/25.
//  Copyright © 2017年 周发明. All rights reserved.
//

import UIKit

class ViewController: UIViewController, FMCarouselViewPrortocol{

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let roll = FMCarouselView(frame: CGRect(), unlimitedCycle: false)
        roll.delegate = self
        self.view.addSubview(roll)
        
        roll.frame = CGRect(x: 0, y: 20, width: 320, height: 500)
        
        roll.items.append("1")
        roll.items.append("2")
        roll.items.append("3")
        roll.items.append("4")
        roll.items.append("5")
//        roll.items.append("http://pic.bizhi360.com/bpic/20/6120.jpg")
//        roll.items.append(UIImage(named: "111111111")!)
//        roll.items.append("1")
//        roll.items.append("http://pic.bizhi360.com/bpic/20/6120.jpg")
//        roll.items.append(UIImage(named: "111111111")!)
        roll.reloadItems()
    }

}


extension ViewController {
    func taped(carouselView: FMCarouselView, index: Int) {
        print("点击了第几张---\(index)")
    }
}
