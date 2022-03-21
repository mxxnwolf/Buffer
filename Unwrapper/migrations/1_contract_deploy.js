const USDT = artifacts.require("USDT");
const wUSDT = artifacts.require("wUSDT");
const Unwrapper = artifacts.require("Unwrapper");

module.exports = async function (deployer) {
  let usdt, wusdt;
  await deployer.deploy(USDT).then(() => {
    usdt = USDT.address;
    console.log(`USDT Address : ${usdt}`);
  })
  await deployer.deploy(wUSDT).then(() => {
    wusdt = wUSDT.address;
    console.log(`wUSDT Address : ${wusdt}`);
  })
  deployer.deploy(Unwrapper, usdt, wusdt).then(() => {
    console.log(`Unwrapper Address : ${Unwrapper.address}`);
  })
};