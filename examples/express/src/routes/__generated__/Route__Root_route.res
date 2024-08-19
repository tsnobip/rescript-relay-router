// @generated
// This file is autogenerated from `routes.json`, do not edit manually.
module Internal = {
  @live
  type childPathParams = {
    byStatus: option<[#completed | #notCompleted]>,
    todoId: option<string>,
  }

  @live
  type prepareProps = {
    environment: RescriptRelay.Environment.t,
    location: RelayRouter.History.location,
    childParams: childPathParams,
  }

  @live
  type renderProps<'prepared> = {
    childRoutes: React.element,
    prepared: 'prepared,
    environment: RescriptRelay.Environment.t,
    location: RelayRouter.History.location,
    childParams: childPathParams,
  }

  @live
  type renderers<'prepared> = {
    prepare: prepareProps => 'prepared,
    prepareCode: option<(. prepareProps) => array<RelayRouter.Types.preloadAsset>>,
    render: renderProps<'prepared> => React.element,
  }
  @live
  let makePrepareProps = (. 
    ~environment: RescriptRelay.Environment.t,
    ~pathParams: Js.Dict.t<string>,
    ~queryParams: RelayRouter.Bindings.QueryParams.t,
    ~location: RelayRouter.History.location,
  ): prepareProps => {
    ignore(queryParams)
    {
      environment: environment,
  
      location: location,
      childParams: Obj.magic(pathParams),
    }
  }

}



@inline
let routePattern = "/"

@live
let makeLink = () => {
  RelayRouter.Bindings.generatePath(routePattern, Js.Dict.fromArray([]))
}

@live
let isRouteActive = (~exact: bool=false, {pathname}: RelayRouter.History.location): bool => {
  RelayRouter.Internal.matchPathWithOptions({"path": routePattern, "end": exact}, pathname)->Belt.Option.isSome
}

@live
let useIsRouteActive = (~exact=false) => {
  let location = RelayRouter.Utils.useLocation()
  React.useMemo(() => location->isRouteActive(~exact), (location, exact))
}
@live
type subRoute = [#Todos]

@live
let getActiveSubRoute = (location: RelayRouter.History.location): option<[#Todos]> => {
  let {pathname} = location
  if RelayRouter.Internal.matchPath("/todos", pathname)->Belt.Option.isSome {
      Some(#Todos)
    } else {
    None
  }
}

@live
let useActiveSubRoute = (): option<[#Todos]> => {
  let location = RelayRouter.Utils.useLocation()
  React.useMemo(() => {
    getActiveSubRoute(location)
  }, [location])
}



@obj
external makeRenderer: (
  ~prepare: Internal.prepareProps => 'prepared,
  ~prepareCode: Internal.prepareProps => array<RelayRouter.Types.preloadAsset>=?,
  ~render: Internal.renderProps<'prepared> => React.element,
) => Internal.renderers<'prepared> = ""