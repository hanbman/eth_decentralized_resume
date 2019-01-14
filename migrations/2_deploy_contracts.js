var Resume = artifacts.require("./Resume.sol");
var BokkyPooBahsDateTimeLibrary = artifacts.require("./BokkyPooBahsDateTimeLibrary.sol");
var SafeMath = artifacts.require("./SafeMath.sol");

module.exports = function(deployer) {
  deployer.deploy(BokkyPooBahsDateTimeLibrary);
  deployer.link(BokkyPooBahsDateTimeLibrary, Resume);
  deployer.deploy(SafeMath);
  deployer.link(SafeMath, Resume);
  deployer.deploy(Resume);
};

