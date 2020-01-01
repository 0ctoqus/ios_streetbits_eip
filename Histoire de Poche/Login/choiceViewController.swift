//
//  HomeTableViewCell.swift
//  Histoire de Poche
//
//  Created by OLIVETTI Octave on 01/04/2017.
//  Copyright © 2017 OLIVETTI Octave. All rights reserved.
//

import UIKit

class choiceViewController: UIViewController
{
   override func viewDidLoad()
    {
        super.viewDidLoad()
        
    }

    override func didReceiveMemoryWarning()
    {
		super.didReceiveMemoryWarning()		
        // Dispose of any resources that can be recreated.
    }
    
    override func viewDidAppear(_ animated: Bool)
    {
        let userId = UserDefaults.standard.object(forKey: "userId") as? String
        let userToken = UserDefaults.standard.object(forKey: "userToken") as? String
        if (userId != nil || userToken != nil)
        {
            DispatchQueue.main.async()
			{
                    self.dismiss(animated: true, completion: {});
            }
        }
    }
    
}
