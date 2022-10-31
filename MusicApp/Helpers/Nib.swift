//
//  Nib.swift
//  MusicApp
//
//  Created by Maksim Grischenko on 20.10.2022.
//

import UIKit

extension UIView {
    class func loadFromNib<T: UIView>() -> T {
        return Bundle.main.loadNibNamed(String(describing: T.self), owner: nil)![0] as! T
    }
}
