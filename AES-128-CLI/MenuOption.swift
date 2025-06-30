class MenuOption : MenuComponent {
    let name : String
    var executeFunc: ()  -> Void = {}
    init(_ name: String) {
        self.name = name
    }
    
    init(name: String, executeFunc: @escaping () -> Void) {
        self.name = name
        self.executeFunc = executeFunc
    }
    
    public func getName() -> String {
        return name
    }
    
    public func execute()  {
        executeFunc()
    }
    
}
