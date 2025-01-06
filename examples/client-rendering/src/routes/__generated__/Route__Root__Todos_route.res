// @generated
// This file is autogenerated from `todoRoutes.json`, do not edit manually.
type queryParams = {
  statuses: option<array<TodoStatus.t>>,
  statusWithDefault: TodoStatus.t,
}

module Internal = {
  @live
  type childPathParams = {
    byStatus: option<[#"completed" | #"not-completed"]>,
    byStatusDecoded: option<TodoStatusPathParam.t>,
    todoId: option<string>,
  }

  @live
  type prepareProps = {
    environment: RescriptRelay.Environment.t,
    location: RelayRouter.History.location,
    ...queryParams,
    childParams: childPathParams,
  }

  @live
  type renderProps<'prepared> = {
    childRoutes: React.element,
    prepared: 'prepared,
    environment: RescriptRelay.Environment.t,
    location: RelayRouter.History.location,
    ...queryParams,
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
    ~pathParams: dict<string>,
    ~queryParams: RelayRouter.Bindings.QueryParams.t,
    ~location: RelayRouter.History.location,
  ): prepareProps => {
    {
      environment: environment,
  
      location: location,
      childParams: Obj.magic(pathParams),
      statuses: queryParams->RelayRouter.Bindings.QueryParams.getArrayParamByKey("statuses")->Option.map(value => value->Array.filterMap(value => value->decodeURIComponent->TodoStatus.parse)),
      statusWithDefault: queryParams->RelayRouter.Bindings.QueryParams.getParamByKey("statusWithDefault")->Option.flatMap(value => value->decodeURIComponent->TodoStatus.parse)->Option.getOr(TodoStatus.defaultValue),
    }
  }

}

@live
let parseQueryParams = (search: string): queryParams => {
  open RelayRouter.Bindings
  let queryParams = QueryParams.parse(search)
  {
    statuses: queryParams->QueryParams.getArrayParamByKey("statuses")->Option.map(value => value->Array.filterMap(value => value->decodeURIComponent->TodoStatus.parse)),

    statusWithDefault: queryParams->QueryParams.getParamByKey("statusWithDefault")->Option.flatMap(value => value->decodeURIComponent->TodoStatus.parse)->Option.getOr(TodoStatus.defaultValue),

  }
}

@live
let applyQueryParams = (
  queryParams: RelayRouter__Bindings.QueryParams.t,
  ~newParams: queryParams,
) => {
  open RelayRouter__Bindings

  
  queryParams->QueryParams.setParamArrayOpt(~key="statuses", ~value=newParams.statuses->Option.map(statuses => statuses->Array.map(statuses => statuses->TodoStatus.serialize->encodeURIComponent)))
  queryParams->QueryParams.setParam(~key="statusWithDefault", ~value=newParams.statusWithDefault->TodoStatus.serialize->encodeURIComponent)
}

@live
type useQueryParamsReturn = {
  queryParams: queryParams,
  setParams: (
    ~setter: queryParams => queryParams,
    ~onAfterParamsSet: queryParams => unit=?,
    ~navigationMode_: RelayRouter.Types.setQueryParamsMode=?,
    ~removeNotControlledParams: bool=?,
    ~shallow: bool=?,
  ) => unit
}

@live
let useQueryParams = (): useQueryParamsReturn => {
  let {search} = RelayRouter.Utils.useLocation()
  let currentQueryParams = React.useMemo(() => {
    search->parseQueryParams
  }, [search])

  {
    queryParams: currentQueryParams,
    setParams: RelayRouter__Internal.useSetQueryParams(~parseQueryParams, ~applyQueryParams),
  }
}

@inline
let routePattern = "/todos"

@live
let makeLink = (~statuses: option<array<TodoStatus.t>>=?, ~statusWithDefault: option<TodoStatus.t>=?) => {
  open RelayRouter.Bindings
  let queryParams = QueryParams.make()
  switch statuses {
    | None => ()
    | Some(statuses) => queryParams->QueryParams.setParamArray(~key="statuses", ~value=statuses->Array.map(value => value->TodoStatus.serialize->encodeURIComponent))
  }

  switch statusWithDefault {
    | None => ()
    | Some(statusWithDefault) => queryParams->QueryParams.setParam(~key="statusWithDefault", ~value=statusWithDefault->TodoStatus.serialize->encodeURIComponent)
  }
  RelayRouter.Bindings.generatePath(routePattern, Dict.fromArray([])) ++ queryParams->QueryParams.toString
}
@live
let makeLinkFromQueryParams = (queryParams: queryParams) => {
  makeLink(~statuses=?queryParams.statuses, ~statusWithDefault=queryParams.statusWithDefault, )
}

@live
let useMakeLinkWithPreservedPath = (): ((queryParams => queryParams) => string) => RelayRouter__Internal.useMakeLinkWithPreservedPath(~parseQueryParams, ~applyQueryParams)


@live
let isRouteActive = (~exact: bool=false, {pathname}: RelayRouter.History.location): bool => {
  RelayRouter.Internal.matchPathWithOptions({"path": routePattern, "end": exact}, pathname)->Option.isSome
}

@live
let useIsRouteActive = (~exact=false) => {
  let location = RelayRouter.Utils.useLocation()
  React.useMemo(() => location->isRouteActive(~exact), (location, exact))
}
@live
type subRoute = [#ByStatus | #ByStatusDecoded | #Single]

@live
let getActiveSubRoute = (location: RelayRouter.History.location): option<[#ByStatus | #ByStatusDecoded | #Single]> => {
  let {pathname} = location
  if RelayRouter.Internal.matchPath("/todos/:byStatus(completed|not-completed)", pathname)->Option.isSome {
      Some(#ByStatus)
    } else if RelayRouter.Internal.matchPath("/todos/:byStatusDecoded", pathname)->Option.isSome {
      Some(#ByStatusDecoded)
    } else if RelayRouter.Internal.matchPath("/todos/:todoId", pathname)->Option.isSome {
      Some(#Single)
    } else {
    None
  }
}

@live
let useActiveSubRoute = (): option<[#ByStatus | #ByStatusDecoded | #Single]> => {
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