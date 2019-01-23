App = {
  web3Provider: null,
  contracts: {},

  init: function() {
    // Load the web3 javascript library to interact with Eth blockchain
    return App.initWeb3();
  },

  initWeb3: function() {
    // Is there an injected web3 instance?
    if (typeof web3 !== 'undefined') {
      App.web3Provider = web3.currentProvider;
    } else {
      // If no injected web3 instance is detected, fall back to Ganache
      App.web3Provider = new Web3.providers.HttpProvider('http://localhost:7545');
    }
    web3 = new Web3(App.web3Provider);

    return App.initContract();
  },

  initContract: function() {
    $.getJSON('Resume.json', function(data) {
      // Get the necessary contract artifact file and instantiate it with truffle-contract
      var ResumeArtifact = data;
      // Truffle contract is redundant to web3, but allows you to absorb truffle build files
      // with deployed addresses and ABIs that you  would have to set otherwise in Web3 - NJ
      App.contracts.Resume = TruffleContract(ResumeArtifact);

      // Set the provider for our contract
      App.contracts.Resume.setProvider(App.web3Provider);

    });

    return App.bindEvents();
  },

  bindEvents: function() {
    $(document).on('click', '#submit', App.handleUserSignUp);
  },

  handleUserSignUp: function(event) {
    event.preventDefault();

    var userName = document.getElementById('username').value
    //var userName = parseString($(event.target).data('id'));
    var resumeInstance;

    web3.eth.getAccounts(function(error, accounts) {
      if (error) {
        console.log(error);
      }

      var account = accounts[0];

      App.contracts.Resume.deployed().then(function(instance) {
        resumeInstance = instance;

        // Execute sign up as a transaction by sending account and userName
        return resumeInstance.signUpUser(userName, {from: account});
      })
    });
  }

};

$(function() {
  $(window).load(function() {
    App.init();
  });
});