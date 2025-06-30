struct CLIApp {
  static func main() {
    let arguments = CommandLine.arguments

    if arguments.count > 1 {
        CLI.main()
    } else {
        CLIInteractive.run()
    }
  }
}

CLIApp.main()
