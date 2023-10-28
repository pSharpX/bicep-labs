using 'main.bicep'

param environment = 'dev'
param configStoreName = 'your_configstore_name'

param keyValues = [
  {
    type: 'feature_flag'
    name: 'addToWallet'
    enabled: false
    description: 'Turn on/off "Add to Wallet" feature  in Mobile Application'
  }
  {
    type: 'feature_flag'
    name: 'scanQr'
    enabled: true
    description: 'Turn on/off "Scan QR" feature  in Mobile Application'
  }
  {
    type: 'keyvault_ref'
    name: 'client-secret'
    secretUrl: 'https://{vault-name}.{vault-DNS-suffix}/secrets/{secret-name}/{secret-version}'
  }
]
