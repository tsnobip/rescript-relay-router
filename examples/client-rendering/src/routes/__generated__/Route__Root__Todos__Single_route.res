// @generated
// This file is autogenerated from `todoRoutes.json`, do not edit manually.
@live
type pathParams = {
  todoId: string,
}

type queryParams = {
  statuses: option<array<TodoStatus.t>>,
  statusWithDefault: TodoStatus.t,
  byValue: option<string>,
  showMore: option<bool>,
}

module Internal = {
  @live
  type prepareProps = {
    environment: RescriptRelay.Environment.t,
    location: RelayRouter.History.location,
    ...pathParams,
    ...queryParams,
  }

  @live
  type renderProps<'prepared> = {
    childRoutes: React.element,
    prepared: 'prepared,
    environment: RescriptRelay.Environment.t,
    location: RelayRouter.History.location,
    ...pathParams,
    ...queryParams,
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
      todoId: pathParams->Dict.getUnsafe("todoId"),
      statuses: queryParams->RelayRouter.Bindings.QueryParams.getArrayParamByKey("statuses")->Option.map(value => value->Array.filterMap(value => value->TodoStatus.parse)),
      statusWithDefault: queryParams->RelayRouter.Bindings.QueryParams.getParamByKey("statusWithDefault")->Option.flatMap(value => value->TodoStatus.parse)->Option.getOr(TodoStatus.defaultValue),
      byValue: queryParams->RelayRouter.Bindings.QueryParams.getParamByKey("byValue")->Option.flatMap(value => Some(value)),
      showMore: queryParams->RelayRouter.Bindings.QueryParams.getParamByKey("showMore")->Option.flatMap(value => switch value {
        | "true" => Some(true)
        | "false" => Some(false)
        | _ => None
        }),
    }
  }

}

@live
let parseQueryParams = (search: string): queryParams => {
  open RelayRouter.Bindings
  let queryParams = QueryParams.parse(search)
  {
    statuses: queryParams->QueryParams.getArrayParamByKey("statuses")->Option.map(value => value->Array.filterMap(value => value->TodoStatus.parse)),

    statusWithDefault: queryParams->QueryParams.getParamByKey("statusWithDefault")->Option.flatMap(value => value->TodoStatus.parse)->Option.getOr(TodoStatus.defaultValue),

    byValue: queryParams->QueryParams.getParamByKey("byValue")->Option.flatMap(value => Some(value)),

    showMore: queryParams->QueryParams.getParamByKey("showMore")->Option.flatMap(value => switch value {
      | "true" => Some(true)
      | "false" => Some(false)
      | _ => None
      }),

  }
}

@live
let applyQueryParams = (
  queryParams: RelayRouter__Bindings.QueryParams.t,
  ~newParams: queryParams,
) => {
  open RelayRouter__Bindings

  
  queryParams->QueryParams.setParamArrayOpt(~key="statuses", ~value=newParams.statuses->Option.map(statuses => statuses->Array.map(statuses => statuses->TodoStatus.serialize)))
  queryParams->QueryParams.setParam(~key="statusWithDefault", ~value=newParams.statusWithDefault->TodoStatus.serialize)
  queryParams->QueryParams.setParamOpt(~key="byValue", ~value=newParams.byValue->Option.map(byValue => byValue))
  queryParams->QueryParams.setParamOpt(~key="showMore", ~value=newParams.showMore->Option.map(showMore => switch showMore { | true => "true" | false => "false" }))
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
let routePattern = "/todos/:todoId"

@live
let makeLink = (~todoId: string, ~statuses: option<array<TodoStatus.t>>=?, ~statusWithDefault: option<TodoStatus.t>=?, ~byValue: option<string>=?, ~showMore: option<bool>=?) => {
  open RelayRouter.Bindings
  let queryParams = QueryParams.make()
  switch statuses {
    | None => ()
    | Some(statuses) => queryParams->QueryParams.setParamArray(~key="statuses", ~value=statuses->Array.map(value => value->TodoStatus.serialize))
  }

  switch statusWithDefault {
    | None => ()
    | Some(statusWithDefault) => queryParams->QueryParams.setParam(~key="statusWithDefault", ~value=statusWithDefault->TodoStatus.serialize)
  }

  switch byValue {
    | None => ()
    | Some(byValue) => queryParams->QueryParams.setParam(~key="byValue", ~value=byValue)
  }

  switch showMore {
    | None => ()
    | Some(showMore) => queryParams->QueryParams.setParam(~key="showMore", ~value=switch showMore { | true => "true" | false => "false" })
  }
  RelayRouter.Bindings.generatePath(routePattern, Dict.fromArray([("todoId", (todoId :> string)->encodeURIComponent)])) ++ queryParams->QueryParams.toString
}
@live
let makeLinkFromQueryParams = (~todoId: string, queryParams: queryParams) => {
  makeLink(~todoId, ~statuses=?queryParams.statuses, ~statusWithDefault=queryParams.statusWithDefault, ~byValue=?queryParams.byValue, ~showMore=?queryParams.showMore, )
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
let usePathParams = (): option<pathParams> => {
  let {pathname} = RelayRouter.Utils.useLocation()
  switch RelayRouter.Internal.matchPath(routePattern, pathname) {
  | Some({params}) => Some(Obj.magic(params))
  | None => None
  }
}

@obj
external makeRenderer: (
  ~prepare: Internal.prepareProps => 'prepared,
  ~prepareCode: Internal.prepareProps => array<RelayRouter.Types.preloadAsset>=?,
  ~render: Internal.renderProps<'prepared> => React.element,
) => Internal.renderers<'prepared> = ""