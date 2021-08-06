//
//  Player.swift
//  Pickleball Pro
//
//  Created by Eric Romrell on 7/17/21.
//

import Foundation

struct Player {
    let id: String
    let name: String
    let imageUrl: String
}

#if DEBUG

extension Player {
    static let eric = Player(id: "1", name: "Eric", imageUrl: "https://lh3.googleusercontent.com/a-/AOh14GgV7KZOgQ3v3H5SeRnbzCTIAc9N2qM9THqjXrC-IHk=s192-c-rg-br100")
    static let jessica = Player(id: "2", name: "Jessica", imageUrl: "https://lh3.googleusercontent.com/ogw/ADea4I4JY2MmoePviD-zBVFyUsSvXRFHEVmW2zxm_p7_VZU=s83-c-mo")
    static let bryan = Player(id: "3", name: "Bryan", imageUrl: "https://upload.wikimedia.org/wikipedia/commons/a/ab/Wilson_logo.jpg")
    static let bob = Player(id: "4", name: "Bob", imageUrl: "https://ucbd7816eb55bb5b3cf5ba90eab0.previews.dropboxusercontent.com/p/thumb/ABM0NKVi0H0huyQkqh6PLPKzVhOIn3JAU4JKXqYCcAQwKTLwT_F017JgMzGsWmB9TnSQB-UfbtH3cPFhx1mruwCkIPlEWXGQU9m17wEyy0KF1kG5T2AoWpCY7JSpjSSTvqg6EujwNnHkAlDcNR_c8TEJTTm_d3ZYvzpqYHtRi-gkr3cLXMwnNXiU8sX4BCvL6sVEGQuC8xeAxS__9umxgOvqCTi2PlVuO6QPOYSvyemmXoB2jI5vx4L3mIEU3sNTXdrc-faCiGbDzZNiemwOL2ilze-c20wcGGm9mKHWYt2i6G2gnevjgRFlExZ62LYfCDN6LEgrKSRyswBOh6BoAIKFXGqfUaYSzRRiGNJNLBzijX6pOOXHIzt2NH8y3AVDmu9XjKQkf9MGfqx64MNUgax3/p.jpeg?fv_content=true&size_mode=5")
}

#endif
