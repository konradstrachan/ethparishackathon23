/** @type import('hardhat/config').HardhatUserConfig */
require("@nomiclabs/hardhat-waffle");
require("dotenv").config();


const PRIVATE_KEY = process.env.PRIVATE_KEY;

module.exports = {
  solidity: "0.8.19",
  networks: {
    //Linea
    linea: {
      url: `https://rpc.goerli.linea.build/`,
      accounts: [PRIVATE_KEY],
      chainId: 59140,
    },
    //Gnosis
    chiado: {
      url: "https://rpc.chiadochain.net",
      accounts: [PRIVATE_KEY],
      chainId: 10200,
    },
    //Neonlabs
    neonlabs: {
      url: 'https://devnet.neonevm.org',
      accounts: [PRIVATE_KEY],
      chainId: 245022926,
    },
    //Celo
    alfajores: {
      url: "https://alfajores-forno.celo-testnet.org",
      accounts: [PRIVATE_KEY],
      chainId: 44787,
    },
    //Mantle
    mantletestnet: {
      url: "https://rpc.testnet.mantle.xyz/",
      accounts: [PRIVATE_KEY],
      chainId: 5001,
    },
    zkEVM: {
      url: "https://rpc.public.zkevm-test.net",
      accounts: [PRIVATE_KEY],
      chainId: 1442,
    },
  }
};