var MultiSigWallet = artifacts.require("./Multisig.sol");
module.exports = function(deployer) {
  deployer.deploy(MultiSigWallet);
};
