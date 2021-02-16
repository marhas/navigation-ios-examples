//
//  UserLocationAnnotationView.swift
//  Navigation-Examples
//
//  Created by Marcel Hasselaar on 2021-02-11.

import Mapbox

class UserLocationAnnotationView: MGLAnnotationView {
    static let reuseIdentifier = "userLocationAnnotationIcon"

    init() {
        super.init(reuseIdentifier: UserLocationAnnotationView.reuseIdentifier)
        setupImage()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupImage() {
        let imageView = UIImageView(image: UIImage(named: "car_icon_dark"))
        addSubview(imageView)
//        imageView.bound(inside: self)
        frame = imageView.frame
//        bounds = CGRect(origin: CGPoint.zero, size: imageView.image?.size ?? CGSize.zero)
        layer.zPosition = 99.0
    }
}
