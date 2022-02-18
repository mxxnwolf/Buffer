
const { deployProxy, upgradeProxy } = require('@openzeppelin/truffle-upgrades');

const Lotto = artifacts.require('Lotto');


module.exports = async function (deployer) {
  const instance = await deployProxy(Lotto, [], { deployer } , {kind : UUPS});
}