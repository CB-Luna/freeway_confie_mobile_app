library;
// TEST Services List

/// <<<<<<<< Embebed Forms Web >>>>>>>>>
///
const String urlBaseEmbed = 'https://www.acceptance.com/';

const String urlBaseEmbedBuyProduct = 'https://buy.acceptance.com/product/';

const String urlBaseEmbedCarRegistration = 'https://www.carregistration.com/';

const String urlBaseEmbedTriton = 'https://triton.acceptance.com/';

const String urlBaseEmbedTaxmax = 'https://www.taxmax.com/';

const String urlBaseEmbedRate = 'https://rate.acceptance.com/';

const String urlBaseEmbedQuote = 'https://quote.sanborns.com/';

const String urlBaseEmbedSeguros = 'https://www.freewayseguros.com/';

const String urlBaseEmbedQuickPay = 'https://quickpay.acceptance.com/';

/// <<<<<<<< User Profile & Policy >>>>>>>>>
/// <<<<<<<< Login & Registration >>>>>>>>>

const String envLogin = String.fromEnvironment(
  'env',
  defaultValue: 'https://confie-customer-np.azurewebsites.net',
);

const String apiKeyLogin =
    'jEk40pLbflj4vQ6RyhQmI3JxDAXjUhdWrEjYBgQRAuSs8X6ged161peEtM4mM8sT';

/// <<<<<<<< PK Pass Wallet (Google / Apple) >>>>>>>>>

const String envWallet = String.fromEnvironment(
  'env',
  defaultValue: 'https://confie-wallet-api-np.azurewebsites.net',
);

const String apiKeyWallet = 'GfhGdjdx3rfGBBFkf';

/// <<<<<<<< Office Locations >>>>>>>>>

const String envOffice = String.fromEnvironment(
  'env',
  defaultValue: 'https://inquiry.confie.com',
);

const String apiKeyOffice = 'fjzzkOuCefd8-Z86i9HMGWQ=';

const String legalEntity = 'Acceptance Insurance Agency Of Tennessee, Inc.';

/// <<<<<<<< Offices Map >>>>>>>>>
/// <<<<<<<< Thirds Party >>>>>>>>>

const String envThirdsPartyZipcode = 'https://api.zippopotam.us/us/';

const String envThirdsPartyAppleMap = 'https://maps.apple.com/';

const String envThirdsPartyGoogleMap = 'https://www.google.com/maps/';
