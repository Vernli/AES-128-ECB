struct CLIInteractive {
  static func run() {
    let mainMenu       = Menu(name: "Main Menu")
    let encryptionMenu = Menu(name: "Encryption Menu")
    let decryptionMenu = Menu(name: "Decryption Menu")
    
    mainMenu.addMenuOptions([
      MenuOption("Encrypt"),
      MenuOption("Decrypt"),
    ])
    
    encryptionMenu.addMenuOptions([
      MenuOption(name: "Sequential encryption") {
        CLIHandler.encryption(Modes.SEQ)
      },
      MenuOption(name: "Parallel encryption (CPU)") {
          CLIHandler.encryption(Modes.CPU)
      },
      MenuOption(name: "Parallel encryption (GPU)") {
          CLIHandler.encryption(Modes.GPU)
      },
    ])
    
    decryptionMenu.addMenuOptions([
      MenuOption(name: "Sequential decryption") {
          CLIHandler.decryption(Modes.SEQ)
      },
      MenuOption(name: "Parallel decryption (CPU)") {
          CLIHandler.decryption(Modes.CPU)
      },
      MenuOption(name: "Parallel decryption (GPU)") {
          CLIHandler.decryption(Modes.GPU)
      },
    ])
    
    mainMenu.addSubMenus([encryptionMenu, decryptionMenu])
    mainMenu.showMenu()
  }
}
