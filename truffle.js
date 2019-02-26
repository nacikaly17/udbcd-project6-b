const HDWalletProvider = require("truffle-hdwallet-provider");
module.exports = {
  networks: {
    development: {
      host: "127.0.0.1",
      port: 8545,
      network_id: "*" // Match any network id
    },
    rinkeby: {
      provider: function () {
        return new HDWalletProvider("spirit supply whale amount human item harsh scare congress discover talent hamster",
          "https://rinkeby.infura.io/v3/26264308f8d947aab7987f194df1495f")
      },
      network_id: '4',
      gas: 4500000,
      gasPrice: 10000000000,
    }
  }
};

