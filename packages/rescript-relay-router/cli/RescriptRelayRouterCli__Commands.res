module Codegen = RescriptRelayRouterCli__Codegen
module Utils = RescriptRelayRouterCli__Utils
module Types = RescriptRelayRouterCli__Types
module Diagnostics = RescriptRelayRouterCli__Diagnostics

open RescriptRelayRouterCli__Bindings

let scaffoldRouteRenderers = (~deleteRemoved, ~config) => {
  let (_routes, routeNamesDict) = Utils.readRouteStructure(config)
  let existingRenderers = Glob.glob.sync(
    ["**/*_route_renderer.res"],
    {cwd: Utils.pathInRoutesFolder(~config)},
  )

  let routeNamesWithRenderers = Dict.make()

  existingRenderers->Array.forEach(rendererFileName => {
    routeNamesWithRenderers->Dict.set(Utils.fromRendererFileName(rendererFileName), true)
  })

  if deleteRemoved {
    // Remove all renderers that does not have a route defined for it
    existingRenderers->Array.forEach(rendererFileName => {
      switch routeNamesDict->Dict.get(Utils.fromRendererFileName(rendererFileName)) {
      | None =>
        // No route exists with this name, remove the file.
        Console.log("Removing unused renderer \"" ++ rendererFileName ++ "\"")
        Fs.unlinkSync(Utils.pathInRoutesFolder(~config, ~fileName=rendererFileName))
      | Some(_) => // Exists, don't mind this
        ()
      }
    })
  }

  // Let's add renderers for any route that doesn't already have one
  routeNamesDict
  ->Dict.toArray
  ->Array.forEach(((routeName, (route, _))) => {
    switch routeNamesWithRenderers->Dict.get(routeName) {
    | Some(_) => // Renderer exists, don't touch anything
      ()
    | None =>
      // No renderer, lets write it

      Fs.writeFileIfChanged(
        Utils.pathInRoutesFolder(~config, ~fileName=Utils.toRendererFileName(routeName)),
        `let renderer = Routes.${route.name->Types.RouteName.getFullRouteAccessPath}.makeRenderer(
  ~prepare=props => {
    ()
  },
  ~render=props => {
    React.null
  },
  (),
)`,
      )

      Console.log("Added \"" ++ Utils.toRendererFileName(routeName) ++ "\"")
    }
  })
}

let generateRoutes = (~scaffoldAfter, ~deleteRemoved, ~config) => {
  Console.log("Generating routes...")
  let (routes, routeNamesDict) = Utils.readRouteStructure(config)

  let routesFile = ref(`// @generated
// This file is autogenerated, do not edit manually\n`)

  routes->Array.forEach(route => {
    routesFile->Utils.add(route->Utils.printNestedRouteModules(~indentation=0))
  })

  // Let's start by writing the Routes file
  Fs.writeFileIfChanged(
    Utils.pathInGeneratedFolder(~config, ~fileName="Routes.res"),
    routesFile.contents,
  )

  let currentFilesInOutputTarget = Glob.glob.sync(
    ["Route__*_route.res"],
    {cwd: Utils.pathInGeneratedFolder(~config)},
  )

  // Remove files in the generated folder no longer needed
  currentFilesInOutputTarget->Array.forEach(fileName => {
    let shouldDelete = switch (
      fileName->String.endsWith("_route.res"),
      fileName->String.startsWith("Route__"),
    ) {
    | (true, true) =>
      let routeName =
        fileName
        ->String.sliceToEnd(~start=String.length("Route__"))
        ->String.replace("_route.res", "")

      routeNamesDict->Dict.get(routeName)->Option.isNone
    | _ => false
    }

    if shouldDelete {
      Fs.unlinkSync(Utils.pathInGeneratedFolder(~config, ~fileName))
    }
  })

  // Write route assets
  routeNamesDict
  ->Dict.valuesToArray
  ->Array.forEach(((route, _path)) => {
    let assetsContent =
      `// @generated\n// This file is autogenerated from \`${route.sourceFile}\`, do not edit manually.\n` ++
      Codegen.getPathParamsTypeDefinition(route) ++
      Codegen.getQueryParamTypeDefinition(route) ++
      "module Internal = {\n" ++
      Codegen.getPrepareTypeDefinitions(route) ++
      "}\n\n" ++
      Codegen.getQueryParamAssets(route) ++
      "\n\n" ++
      Codegen.getRouteMakerAndAssets(route) ++
      "\n\n" ++
      Codegen.getActiveRouteAssets(route) ++
      "\n\n" ++
      Codegen.getUsePathParamsHook(route) ++
      "\n\n" ++
      Codegen.getPrepareAssets()

    Fs.writeFileIfChanged(
      Utils.pathInGeneratedFolder(
        ~config,
        ~fileName=`${route.name->Types.RouteName.toGeneratedRouteModuleName}.res`,
      ),
      assetsContent,
    )
  })

  let routeNamesEntries = routeNamesDict->Dict.toArray

  // Write the full route declarations file
  let fileContents = `
open RelayRouter__Internal__DeclarationsSupport

external unsafe_toPrepareProps: 'any => prepareProps = "%identity"

let loadedRouteRenderers: Belt.HashMap.String.t<loadedRouteRenderer> = Belt.HashMap.String.make(
  ~hintSize=${routeNamesEntries->Array.length->Int.toString},
)

let make = (~prepareDisposeTimeout=5 * 60 * 1000): array<RelayRouter.Types.route> => {
  let {prepareRoute, getPrepared} = makePrepareAssets(~loadedRouteRenderers, ~prepareDisposeTimeout)

  [
    ${routes
    ->Array.map(route => Codegen.getRouteDefinition(route, ~indentation=1))
    ->Array.joinWith(",\n")}
  ]
}`

  Utils.pathInGeneratedFolder(~config, ~fileName="RouteDeclarations.res")->Fs.writeFileIfChanged(
    fileContents,
  )

  // Write interface file as the signature of this will never change
  Utils.pathInGeneratedFolder(
    ~config,
    ~fileName="RouteDeclarations.resi",
  )->Fs.writeFileIfChanged(`let make: (~prepareDisposeTimeout: int=?) => array<RelayRouter.Types.route>`)

  if scaffoldAfter {
    scaffoldRouteRenderers(~deleteRemoved, ~config)
  }

  Console.log("Done!")
}

// This does a simple lookup of any route provided to it. Currently does not
// support query params since they need to be decoded before we can know they
// work.
let printRouteInfo = (~url, ~config) => {
  let (routes, _routeNamesDict) = Utils.readRouteStructure(config)
  let urlObj = URL.make(
    switch url->String.startsWith("http") {
    | true => url
    | false => "http://localhost" ++ url
    },
  )

  let matched =
    routes
    ->Array.map(Utils.rawRouteToMatchable)
    ->Utils.matchRoutesCli({
      "pathname": urlObj->URL.getPathname,
      "search": urlObj->URL.getSearch->Option.getOr(""),
      "hash": urlObj->URL.getHash,
      "state": urlObj->URL.getState,
    })
    ->Option.getOr([])

  switch matched->Array.length {
  | 0 => Console.log("URL did not match any routes.")
  | matchCount =>
    let str = ref(`URL matched ${matchCount->Int.toString} route(s).\n\n===== Matched structure:\n`)
    let indentation = ref(0)
    let strEnd = ref("")

    matched->Array.forEachWithIndex((matchedRoute, index) => {
      let propsForRoute =
        matchedRoute.params
        ->Dict.toArray
        ->Array.filter(((key, _)) => matchedRoute.route.params->Array.includes(key))

      str.contents =
        str.contents ++
        "\n" ++
        `${String.repeat("  ", indentation.contents)}// In "${matchedRoute.route.sourceFile}"\n` ++
        String.repeat("  ", indentation.contents) ++
        `<${matchedRoute.route.name}${propsForRoute
          ->Array.map(((key, value)) => {
            ` ${key}="${value}"`
          })
          ->Array.joinWith("")}>`

      if index + 1 !== matchCount {
        strEnd.contents =
          strEnd.contents ++
          "\n" ++
          String.repeat("  ", indentation.contents) ++
          `</${matchedRoute.route.name}>`
      }

      indentation.contents = indentation.contents + 1
    })

    Console.log(
      str.contents ++
      "\n" ++ {
        let contents = strEnd.contents->String.split("\n")
        contents->Array.reverse
        contents->Array.joinWith("\n")
      },
    )
  }
}

@val
external stringifyFormatted: ('any, @as(json`null`) _, @as(json`2`) _) => string = "JSON.stringify"

let init = () => {
  if !Utils.Config.exists() {
    Console.log("[init] Config does not exist, creating default one...")
    let path = Path.resolve([Process.cwd(), "./rescriptRelayRouter.config.cjs"])

    Fs.writeFileSync(
      path,
      `module.exports = ${{
          "routesFolderPath": "./src/routes",
        }->stringifyFormatted}`,
    )

    Console.log("[init] Config created at: " ++ path)
  } else {
    Console.log("[init] Config exists, moving on...")
  }

  try {
    let config = Utils.Config.load()
    let routesJsonPath = Utils.pathInRoutesFolder(~config, ~fileName="routes.json")

    if !Fs.existsSync(routesJsonPath) {
      Console.log("[init] `routes.json` does not exist, creating...")
      Fs.writeFileSync(
        routesJsonPath,
        (
          {
            "path": "/",
            "name": "Root",
            "children": [],
          },
          {
            "path": "*",
            "name": "FourOhFour",
          },
        )->stringifyFormatted,
      )

      Console.log("[init] Basic `routes.json` added at: " ++ routesJsonPath)
    }
  } catch {
  | Utils.Invalid_config(_) =>
    Console.log(
      "[init] Config existed, but was misconfigured. Re-configure it and rerun this command.",
    )
    Process.exit(0)
  }

  Console.log("[init] Done! You can now run the `generate -scaffold-renderers` command.")
}

type cliResult = Done | Watcher({watchers: array<Chokidar.Watcher.t>})

let runCli = args => {
  switch args->List.fromArray {
  | list{"-help" | "-h", ..._rest} =>
    Console.log(`Usage:
  init                                                      | Inits the config for the router.

  lsp                                                       | Starts a language server for the router.
    [-stdio]                                                |   [-stdio] will start the LS in stdio mode. Default is Node RPC mode.

  generate
    [-scaffold-renderers] [-delete-removed] [-w, --watch]   | Generates all routing code. Run this after making changes.
                                                            |   [-scaffold-renderers] will also run the command to scaffold 
                                                            |   route renderers.
                                                            |   [-w, --watch] runs this command in watch mode.

  scaffold-route-renderers
    [-delete-removed]                                       | Will automatically add route renderer files for all routes that 
                                                            | do not have them. 
                                                            |   [-delete-removed] will remove any route renderer that does not 
                                                            |   have a route defined anymore.

  find-route <url>                                          | Shows what routes/components will render for a specific route.
                                                            | Example: find-route /todos/123`)
    Done
  | list{"scaffold-route-renderers", ...options} =>
    let deleteRemoved = options->List.has("-delete-removed", \"=")
    let config = Utils.Config.load()

    Utils.ensureRouteStructure(config.routesFolderPath)

    Console.log("Scaffolding route renderers...")
    try {
      scaffoldRouteRenderers(~deleteRemoved, ~config)
      Console.log("Done!")
    } catch {
    | Utils.Decode_error(routeStructure) => routeStructure->Diagnostics.printDiagnostics(~config)
    }
    Done
  | list{"generate", ...options} => {
      let scaffoldAfterGenerating = options->List.has("-scaffold-renderers", \"=")
      let deleteRemoved = options->List.has("-delete-removed", \"=")
      let shouldWatch = options->List.has("-w", \"=") || options->List.has("--watch", \"=")

      let config = Utils.Config.load()

      Utils.ensureRouteStructure(config.routesFolderPath)

      let generateRoutesSafe = () => {
        try {
          generateRoutes(~scaffoldAfter=scaffoldAfterGenerating, ~deleteRemoved, ~config)
        } catch {
        | Exn.Error(e) => Console.error(e)
        | Utils.Decode_error(routeStructure) =>
          routeStructure->Diagnostics.printDiagnostics(~config)
        | err =>
          Console.log(
            "Something went wrong generating your routes. Please check the validity of `routes.json`.",
          )
          Console.log(err)
        }
      }

      generateRoutesSafe()

      if shouldWatch {
        open Chokidar

        Console.log("Watching routes...")

        let theWatcher =
          watcher
          ->watch(Utils.pathInRoutesFolder(~config, ~fileName="*.json"))
          ->Watcher.onChange(_ => {
            generateRoutesSafe()
          })
          ->Watcher.onUnlink(_ => {
            generateRoutesSafe()
          })
        Watcher({watchers: [theWatcher]})
      } else {
        Done
      }
    }

  | list{"find-route", route} =>
    let config = Utils.Config.load()
    printRouteInfo(~url=route, ~config)
    Done
  | list{"init"} =>
    init()
    Done

  | list{"lsp", ...options} =>
    let config = Utils.Config.load()
    let mode = if options->List.has("-stdio", \"=") {
      Lsp.Stdio
    } else {
      NodeRpc
    }
    let watchers = Lsp.start(~config, ~mode)
    Watcher({watchers: watchers})
  | _ =>
    Console.log("Unknown command. Use -help or -h to see all available commands.")
    Done
  }
}
