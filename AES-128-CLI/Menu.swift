import Foundation

class Menu : MenuComponent {
    var subMenus: [MenuComponent] = []          // MenuComponent
    var menuOptions: [MenuOption] = [] // Leaf
    let inputText: String

    private var name: String
    
    init(name: String, _ inputText: String = "Option: ") {
        self.name = name
        self.inputText = inputText
    }
    
    public func getName() -> String {
        return self.name;
    }
    
    public func setName(name: String) {
        self.name = name
    }
    
    public func addMenuOption(_ option: MenuOption) {
        menuOptions.append(option)
    }
    
    public func addMenuOptions(_ options: [MenuOption]) {
        options.forEach {option in self.menuOptions.append(option)}
    }
    
    override func addSubMenu(_ menuComponent: MenuComponent) {
        subMenus.append(menuComponent)
        menuComponent.parent = self
    }
    
    override func addSubMenus(_ menuComponents: [MenuComponent]) {
        menuComponents.forEach {menu in subMenus.append(menu)}
        subMenus.forEach {menu in menu.parent = self}
    }
    
    override func showMenu() {
        menuOptions.enumerated().forEach(
            { print("\($0+1). \($1.getName())")}
        )
        if(parent != nil) {
            print("0. Back")
        }
        else {
            print("0. Exit")
        }
        userInput(inputText)
    }

    
    public func userInput(_ text: String)  {
        let input = readInt(text: text)
        if (input == 0 && parent != nil) {
             parent?.showMenu()
        }
        else if (input > menuOptions.count && parent != nil) {
            print("Invalid option!")
            parent?.showMenu()
        }
        else if (input == 0 && parent == nil){
            exit(0)
        }
        
        if (subMenus.count >= input && input >= 0) {
            subMenus[input-1].showMenu()
        }
        menuOptions[input-1].execute()
    }
        
    public func readInt(text: String) -> Int {
        print(text, terminator: " ")
        guard let line = readLine(),
              let number = Int(line) else {
            print("Error: invalid format. Please try again.")
            return readInt(text: text)
        }
        return number
    }
    
//
    public func execute(){
        
    }
}
