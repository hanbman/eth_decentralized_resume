var Resume = artifacts.require('Resume')

contract('Resume', function(accounts) {
    
    const owner = accounts[0]
    const alice = accounts[1]
    const bob = accounts[2]
    const ashley = accounts[3]
    const emptyAddress = '0x0000000000000000000000000000000000000000'

    const deploy = async function() {
        resume = await Resume.new();
      };
    
      describe("Test 3", function() {
        beforeEach(deploy);

        it("Owner should be able to set the sign up fee. User should be able to sign up.", async() => {
            //verify ashley's ether balance before transactions
            var ashleyBalanceBefore = await web3.eth.getBalance(ashley)
            
            //deploy the contract
            const resume = await Resume.deployed()
            //owner adds alice as admin
            await resume.addAdmin(alice, {from: owner})
            //set parameters of institution
            const inst_name = "School of Hard Knocks"
            const type = 1
            //alice adds bob as an institution
            await resume.addInstitution(inst_name, bob, type, {from: alice})

            //owner sets the sign up fee for new users
            const fee = 10
            set_fee = await resume.setSignUpFee(fee, {from: owner})

            //ashley signs up and pays the sign up fee
            const name = "Ashley"
            const amount = 10
            sign_up = await resume.signUpUser(name, {from: ashley, value: amount})

            //record ashley's balance after the transactions
            var ashleyBalanceAfter = await web3.eth.getBalance(ashley)

            assert.equal(set_fee.logs[0].event, "SignUpFeeSet", 'owner was unable to set the fee')
            assert.equal(set_fee.logs[0].args.fee, 10, 'fee was not set to 10')

            assert.equal(sign_up.logs[0].event, "AddedUser", 'user was unable to sign up')
            assert.equal(sign_up.logs[0].args.UserID, 1, 'user was not set with ID = 1')
            assert.notEqual(parseInt(ashleyBalanceBefore), parseInt(ashleyBalanceAfter), 'user was not charged sign up fee')
        })
    })
})