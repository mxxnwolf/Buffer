// migrations/NN_deploy_upgradeable_box.js
const { deployProxy } = require('@openzeppelin/truffle-upgrades');

const Lotto = artifacts.require('Lotto');

module.exports = async function (deployer) {
  const instance = await deployProxy(Lotto, [], { deployer , kind : 'uups'});
  console.log('Deployed', instance.address);
};