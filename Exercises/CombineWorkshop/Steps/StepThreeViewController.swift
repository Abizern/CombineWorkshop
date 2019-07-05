//
//  StepThreeViewController.swift
//  CombineWorkshop
//
//  Created by Antoine van der Lee on 16/06/2019.
//  Copyright © 2019 SwiftLee. All rights reserved.
//

import UIKit
import Combine

/*
 STEP 3:
 A classic sign up form!

 Validation rules are as followed:
 - Username should not exist yet in the `registeredUsernames` array
 - Username should be 4 characters or more
 - Password should be 8 characters or more
 - Password inputs should match
 - Password should not exist in the `weakPasswords` array
 */

final class StepThreeViewController: UIViewController {

    private let registeredUsernames = ["Erica", "Paul", "Marina", "Benedikt", "Kateryna", "Antoine", "Sally", "Bas"]
    private let weakPasswords = ["password", "00000000", "swiftisland"]

    @IBOutlet private weak var nextButton: UIButton!
    private var validationSubscriber: AnyCancellable?

    @IBOutlet private weak var usernameTextField: UITextField!
    @IBOutlet private weak var passwordTextField: UITextField!
    @IBOutlet private weak var passwordConfirmTextField: UITextField!

    @Published var username: String = ""
    @Published var password: String = ""
    @Published var passwordAgain: String = ""

    var validatedPassword: AnyPublisher<String?, Never> {
        // Password and password again should match
        // Password should be 8 characters or more
        // Password should not exists in the weakPasswords array
        // Use `.eraseToAnyPublisher()` in the end

        Publishers.CombineLatest($password, $passwordAgain) { (pass, passA) -> String? in
            if pass.count > 7 && pass == passA && !self.weakPasswords.contains(pass) {
                return pass
            } else {
                return nil
            }
        }.eraseToAnyPublisher()
    }

    var validatedUsername: AnyPublisher<String?, Never> {
        // Username should not exist yet in the `registeredUsernames` array
        // Username should be 4 characters or more
        $username.map { (username) -> String? in
            if username.count > 3 && !self.registeredUsernames.contains(username) {
                return username
            } else {
                return nil
            }
        }.eraseToAnyPublisher()
    }

    var validatedCredentials: AnyPublisher<(String, String)?, Never> {
        // Bring the validation of password and username together
        Publishers.CombineLatest(validatedUsername, validatedPassword) { (username, password) -> (String, String)? in
            switch (username, password) {
            case let (.some(name), .some(pass)): return (name, pass)
            default: return nil
            }
        }.eraseToAnyPublisher()
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        /// Uncomment this and implement
        self.validationSubscriber = self.validatedCredentials
            .map{ $0 != nil }
            .receive(on: DispatchQueue.main)
            .assign(to: \.isEnabled, on: nextButton)
    }

    private func usernameAvailable(_ username: String, completion: (_ available: Bool) -> Void) {
        let usernameAvailable = !registeredUsernames.contains(username)
        completion(usernameAvailable)
    }

    @IBAction func usernameChanged(_ sender: UITextField) {
        username = sender.text ?? ""
    }

    @IBAction func passwordChanged(_ sender: UITextField) {
        password = sender.text ?? ""
    }

    @IBAction func passwordAgainChanged(_ sender: UITextField) {
        passwordAgain = sender.text ?? ""
    }

}

extension StepThreeViewController: WorkshopStepContaining {
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        didFinish(.step3)
    }
}
