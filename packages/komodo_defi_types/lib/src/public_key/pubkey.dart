/// The reasons why a new address cannot be created. This is useful for the UI
/// to determine why the "Create New Address" button is disabled.
///
/// This does slightly fall into the realm of business logic, but there is a
/// lot of logic for undertanding the conditions under which a new address can
/// be created. We may consider a different approach in the future where we
/// add a layer of abstraction to handle this logic and hide the public
/// properties needed to determine these reasons.
enum CantCreateNewAddressReason {
  maxGapLimitReached,
  maxAddressesReached,
  missingDerivationPath,
  protocolNotSupported,
  derivationModeNotSupported,
  noActiveWallet;
}
