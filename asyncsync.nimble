# Package

version       = "0.2.1"
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

task genDocs, "Build the docs":
    ## importBuilder source code: https://github.com/Alogani/shellcmd-examples/blob/main/src/importbuilder.nim
    let bundlePath = "htmldocs/" & projectName() & ".nim"
    exec("./htmldocs/importbuilder --build src " & bundlePath & " --discardExports")
    exec("nim doc --project --index:on --outdir:htmldocs " & bundlePath)

task pushSuite, "Tests -> genDocs -> git push":
    exec("nimble test")
    genDocsTask()
    exec("git push")