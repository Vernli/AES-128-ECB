class MenuComponent {
    weak var parent: MenuComponent?
    
    func addSubMenu(_ component: MenuComponent) {}
    
    func addSubMenus(_ components: [MenuComponent]) {}
    
    func removeSubMenu(_ component: MenuComponent) {}
    
    func showMenu() {}
}
