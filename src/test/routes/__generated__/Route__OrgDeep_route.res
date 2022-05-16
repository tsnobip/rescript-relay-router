// @generated
// This file is autogenerated from `routes.json`, do not edit manually.
@live
let makeLink = (~slug: string, ~action: string) => {
  `/o/${slug->Js.Global.encodeURIComponent}/sub-thing/${action->Js.Global.encodeURIComponent}`
}

@inline
let routePattern = "/o/:slug/sub-thing/:action"

@live
let isRouteActive = ({pathname}: RelayRouter.Bindings.History.location, ~exact: bool=false, ()): bool => {
  RelayRouter.Internal.matchPathWithOptions({"path": routePattern, "end": exact}, pathname)->Belt.Option.isSome
}

@live
let useIsRouteActive = (~exact=false, ()) => {
  let location = RelayRouter.Utils.useLocation()
  React.useMemo1(() => isRouteActive(location, ~exact, ()), [location])
}

@live
type prepareProps = {
  environment: RescriptRelay.Environment.t,
  location: RelayRouter.Bindings.History.location,
  slug: string,
  action: string,
}

let makeRouteKey = (
  ~pathParams: Js.Dict.t<string>,
  ~queryParams: RelayRouter.Bindings.QueryParams.t
): string => {
  ignore(queryParams)

  "OrgDeep:"
    ++ pathParams->Js.Dict.get("slug")->Belt.Option.getWithDefault("")
    ++ pathParams->Js.Dict.get("action")->Belt.Option.getWithDefault("")

}

@live
let makePrepareProps = (. 
  ~environment: RescriptRelay.Environment.t,
  ~pathParams: Js.Dict.t<string>,
  ~queryParams: RelayRouter.Bindings.QueryParams.t,
  ~location: RelayRouter.Bindings.History.location,
): prepareProps => {
  ignore(queryParams)
  {
    environment: environment,

    location: location,
    slug: pathParams->Js.Dict.unsafeGet("slug"),
    action: pathParams->Js.Dict.unsafeGet("action"),
  }
}

@live
type renderProps<'prepared> = {
  childRoutes: React.element,
  prepared: 'prepared,
  environment: RescriptRelay.Environment.t,
  location: RelayRouter.Bindings.History.location,
  slug: string,
  action: string,
}

@live
type renderers<'prepared> = {
  prepare: prepareProps => 'prepared,
  prepareCode: option<(. prepareProps) => array<RelayRouter.Types.preloadAsset>>,
  render: renderProps<'prepared> => React.element,
}

@obj
external makeRenderer: (
  ~prepare: prepareProps => 'prepared,
  ~prepareCode: prepareProps => array<RelayRouter.Types.preloadAsset>=?,
  ~render: renderProps<'prepared> => React.element,
  unit
) => renderers<'prepared> = ""

