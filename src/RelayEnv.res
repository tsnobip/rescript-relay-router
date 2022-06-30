let preparedAssetsMap = Js.Dict.empty()

let network = RescriptRelay.Network.makeObservableBased(
  ~observableFunction=NetworkUtils.makeFetchQuery(
    ~preloadAsset=RelayRouter.AssetPreloader.clientPreloadAsset(~preparedAssetsMap),
  ),
  // ~subscriptionFunction=NetworkUtils.subscribeFn,
  (),
)

let makeEnvironmentWithNetwork = (~network, ~missingFieldHandlers=?, ()) =>
  RescriptRelay.Environment.make(
    ~network,
    ~missingFieldHandlers=?{missingFieldHandlers},
    ~store=RescriptRelay.Store.make(
      ~source=RescriptRelay.RecordSource.make(),
      ~gcReleaseBufferSize=50,
      ~queryCacheExpirationTime=6 * 60 * 60 * 1000,
      (),
    ),
    (),
  )

let environment = makeEnvironmentWithNetwork(~network, ())

@live
let makeServer = (~onResponseReceived, ~onQueryInitiated, ~preloadAsset) => {
  let network = RescriptRelay.Network.makeObservableBased(
    ~observableFunction=NetworkUtils.makeServerFetchQuery(
      ~onResponseReceived,
      ~onQueryInitiated,
      ~preloadAsset,
    ),
    (),
  )
  makeEnvironmentWithNetwork(~network, ())
}
