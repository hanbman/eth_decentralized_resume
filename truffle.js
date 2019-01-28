const HDWallet = require('truffle-hdwallet-provider');
const infuraKey = "1b99b490ecde47ce98fc0ef53928c4eb";


const fs = require('fs');
const mnemonic = fs.readFileSync("file.secret").toString().trim();

module.exports = {
  // See <http://truffleframework.com/docs/advanced/configuration>
  // for more about customizing your Truffle configuration!
  networks: {
      development: {
          host: "127.0.0.1",
          port: 7545,
          network_id: "*" // Match any network id
      },
      rinkeby: {
        provider: () => new HDWallet(mnemonic, `https://rinkeby.infura.io/${infuraKey}`),
        network_id: 4,          // Rinkeby's id
        gas: 6000000,
      },
  }
};