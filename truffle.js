const HDWalletProvider = require('truffle-hdwallet-provider');

module.exports = {
//   compilers: {
//     solc: '0.4.25'
//   },  
  networks: {
    development: {
      host: "127.0.0.1",
      port: 7545,
      network_id: "*" // Match any network id
    }
  }
};
