//
//  AudioVC.swift
//  Chat-Demo-IOS
//
//  Created by usama farooq on 26/05/2021.
//

import UIKit

class AudioVC: UIViewController {
    
    @IBOutlet weak var hornTouchUp: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        // This will start your action.
        hornTouchUp.addTarget(self, action: #selector(start), for: .touchDown)

        // This will end your action.
        hornTouchUp.addTarget(self, action: #selector(end), for: .touchUpInside)
    }
    @objc func start() {
        hornTouchUp.setImage(UIImage(named: "MicFilled"), for: .normal)
        
    }
    @objc func end() {
        hornTouchUp.setImage(UIImage(named: "Mic"), for: .normal)
        
    }
    
    @IBAction func didTapButton(_ sender: UIButton) {
        self.animate(sender: sender)
    }

    func animate(sender: UIButton) {


    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
