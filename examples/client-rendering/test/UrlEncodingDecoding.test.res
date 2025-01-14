open RescriptRelayRouterTestUtils
open Vitest
open TestingLibraryReact

describe("makeLink", () => {
  test("should generate link with statuses", _t => {
    let link = Routes.Root.Todos.Route.makeLink(
      ~statuses=[TodoStatus.Completed, TodoStatus.NotCompleted],
    )
    expect(link)->Expect.toBe("/todos?statuses=completed,not-completed")
  })

  test("should generate link without statuses", _t => {
    let link = Routes.Root.Todos.Route.makeLink()
    expect(link)->Expect.toBe("/todos")
  })

  test("should generate link correctly URI encoded", _t => {
    let link = Routes.Root.Todos.Route.makeLink(~byValue="/incorrect value, for url")
    expect(link)->Expect.toBe("/todos?byValue=%2Fincorrect%20value%2C%20for%20url")
  })

  test("should omit query param when value is default value", _t => {
    let link = Routes.Root.Todos.Route.makeLink(~statusWithDefault=NotCompleted)
    expect(link)->Expect.toBe("/todos")
  })
})

describe("parsing", () => {
  test("parseRoute correctly decode path and query params", _t => {
    let (pathParams, queryParams) =
      Routes.Root.Todos.Single.Route.parseRoute("/todos/123?showMore=false")->Option.getExn
    expect(pathParams.todoId)->Expect.toBe("123")
    expect(queryParams)->Expect.toStrictEqual({
      statuses: None,
      statusWithDefault: NotCompleted,
      byValue: None,
      showMore: Some(false),
    })
  })
  test("parseRoute correctly decode path and query params with wrong query params", _t => {
    let (pathParams, queryParams) =
      Routes.Root.Todos.Single.Route.parseRoute("/todos/123?byValue=hmm&else=false")->Option.getExn
    expect(pathParams.todoId)->Expect.toBe("123")
    expect(queryParams)->Expect.toStrictEqual({
      statuses: None,
      statusWithDefault: NotCompleted,
      byValue: Some("hmm"),
      showMore: None,
    })
  })
  test("parseRoute returns None when not the right route", _t => {
    let res = Routes.Root.Todos.Single.Route.parseRoute("/other/123?byValue=hmm&else=false")
    expect(res)->Expect.toBe(None)
  })

  test("query params are memoized", _t => {
    let routes = RouteDeclarations.make()
    let routerEnvironment = RelayRouter.RouterEnvironment.makeBrowserEnvironment()
    let (_, routerContext) = RelayRouter.Router.make(
      ~routes,
      ~environment=RelayEnv.environment,
      ~routerEnvironment,
      ~preloadAsset=RelayRouter.AssetPreloader.makeClientAssetPreloader(RelayEnv.preparedAssetsMap),
    )
    let wrapper = ({Wrapper.children: children}) => {
      <RelayRouter.Provider value={routerContext}> {children} </RelayRouter.Provider>
    }
    let {result} = renderHook(
      () => {
        let useQueryParams = Routes.Root.Todos.Route.useQueryParams()
        let {push} = RelayRouter.Utils.useRouter()
        {
          "useQueryParams": useQueryParams,
          "push": push,
        }
      },
      ~options={wrapper: wrapper},
    )
    act(
      () => {
        result.current["push"](
          "?statuses=completed,not-completed&byValue=%2Fincorrect%20value%2C%20for%20url",
        )
      },
    )
    let firstStatuses = result.current["useQueryParams"].queryParams.statuses
    expect(result.current["useQueryParams"].queryParams.byValue->Option.getUnsafe)->Expect.toBe(
      "/incorrect value, for url",
    )
    act(
      () => {
        result.current["useQueryParams"].setParams(
          ~setter=queryParams => {...queryParams, byValue: Some("/new value")},
        )
      },
    )
    let followingStatuses = [result.current["useQueryParams"].queryParams.statuses]
    expect(result.current["useQueryParams"].queryParams.byValue->Option.getUnsafe)->Expect.toBe(
      "/new value",
    )
    act(
      () => {
        result.current["push"]("?statuses=completed,not-completed")
      },
    )
    Array.push(followingStatuses, result.current["useQueryParams"].queryParams.statuses)
    followingStatuses->Array.forEach(statuses => statuses->expect->Expect.toBe(firstStatuses))
  })
})
