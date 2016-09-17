//
//  ViewController.swift
//  Sternidae
//
//  Created by Matthew Lewis on 9/17/16.
//  Copyright © 2016 Kestrel Development. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var compass: CompassView!

    override func viewDidLoad() {
        super.viewDidLoad()
        compass.newPointer()
    }

}

