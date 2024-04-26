# Package

version       = "0.1.1"
author        = "alogani"
description   = "Async primitives working on std/asyncdispatch"
license       = "MIT"
srcDir        = "src"


# Dependencies

requires "nim >= 2.0.2"

task reinstall, "Reinstalls this package":
    var path = "~/.nimble/pkgs2/" & projectName() & "-" & $version & "-*"
    exec("rm -rf " & path)
    exec("nimble install")